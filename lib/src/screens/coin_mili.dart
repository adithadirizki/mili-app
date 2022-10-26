import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/topup.dart';
import 'package:miliv2/src/models/topup_retail.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/coin_card.dart';

enum historyAction {
  toggleFavorite,
  showDetail,
  print,
  contactCS,
}

class CoinMiliScreen extends StatefulWidget {
  final String title;
  final int? openDetail;

  const CoinMiliScreen({Key? key, this.title = 'Koin', this.openDetail})
      : super(key: key);

  @override
  _CoinMiliScreenState createState() => _CoinMiliScreenState();
}

class _CoinMiliScreenState extends State<CoinMiliScreen> {
  final formKey = GlobalKey<FormState>();
  PageController pageController = PageController(initialPage: 0);
  List<TopupHistory> itemsTopup = [];
  List<TopupRetailHistory> itemsTopupRetail = [];
  final TextEditingController textAmountController = TextEditingController();
  String selectedMetode = 'TIKET';
  bool isLoading = true;

  Timer? timer;
  DateTime now = DateTime.now();

  late DateTime firstDate;
  late DateTimeRange dateRange;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    firstDate = DateTime(now.year, now.month - 6);
    dateRange = DateTimeRange(
        start: now.subtract(const Duration(hours: 24 * 28)), end: now);
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await initDB();
      //
      if (widget.openDetail != null) {
        var idx = itemsTopup
            .indexWhere((element) => element.serverId == widget.openDetail);
        if (idx >= 0) {
          detail(itemsTopup[idx]);
        }
      }
      //
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          now = DateTime.now();
        });
      });
    });
  }

  @override
  void dispose() {
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  Future<void> initDB() async {
    setState(() {
      isLoading = true;
    });

    await AppDB.syncTopupHistory();
    await AppDB.syncTopupRetailHistory();

    // Tiket transfer bank
    Condition<TopupHistory> filterDateTopup = TopupHistory_.transactionDate
        .greaterOrEqual(dateRange.start.millisecondsSinceEpoch)
        .and(TopupHistory_.transactionDate.lessOrEqual(dateRange.end
        .add(const Duration(hours: 24))
        .millisecondsSinceEpoch));

    Condition<TopupHistory> filterUserTopup =
    TopupHistory_.userId.equals(userBalanceState.userId);

    final dbTopup = AppDB.topupHistoryDB;
    QueryBuilder<TopupHistory> queryTopup = dbTopup.query(filterDateTopup.and(filterUserTopup))
      ..order(TopupHistory_.transactionDate, flags: 1);
    itemsTopup = queryTopup.build().find();

    // Topup Alfamart/Indomaret
    Condition<TopupRetailHistory> filterDateTopupRetail = TopupRetailHistory_.created_at
        .greaterOrEqual(dateRange.start.millisecondsSinceEpoch)
        .and(TopupRetailHistory_.created_at.lessOrEqual(dateRange.end
        .add(const Duration(hours: 24))
        .millisecondsSinceEpoch));

    Condition<TopupRetailHistory> filterUserTopupRetail =
    TopupRetailHistory_.agenid.equals(userBalanceState.userId);

    final dbTopupRetail = AppDB.topupRetailHistoryDB;
    QueryBuilder<TopupRetailHistory> queryTopupRetail = dbTopupRetail
        .query(filterDateTopupRetail.and(filterUserTopupRetail))
      ..order(TopupRetailHistory_.created_at, flags: 1);
    itemsTopupRetail = queryTopupRetail.build().find();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onRefresh() {
    return initDB();
  }

  FutureOr<void> _handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  void detail(TopupHistory history) {
    infoDialog(context, title: 'Detail', msg: history.notes);
  }

  void copy(TopupHistory history) {
    Clipboard.setData(ClipboardData(text: history.amount.toInt().toString()));
    snackBarDialog(context, 'Nominal disalin');
  }

  void cancelTicket(TopupHistory history) {
    confirmDialog(context,
        title: 'Konfirmasi',
        msg: 'Apakah Anda akan membatalkan Tiket ?', confirmAction: () {
      Api.cancelTopupTicket(history.serverId).then((response) {
        debugPrint('Cancel ticket ${response.body}');
        if (response.statusCode == 200) {
          initDB();
        }
      }).catchError(_handleError);
    });
  }

  Widget buildTopupHistoryItem(TopupHistory history) {
    // bool isDebit = data.debitAmount > 0;
    // String description = data.description;
    // if (data.productName != null &&
    //     data.productDetail != null &&
    //     data.productDetail!.isNotEmpty) {
    //   description =
    //       'Pembelian ${data.productName!.trim()} ke ${data.productDetail!.trim()}';
    // } else if (data.productName != null) {
    //   description = '${data.productName!.trim()}';
    // }
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
      // color: Colors.white,
      child: GestureDetector(
        onTap: () {
          detail(history);
        },
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  formatDate(history.transactionDate),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  formatNumber(history.amount),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    history.isSuccess
                        ? history.notes
                        : (history.isFailed ? 'Dibatalkan' : 'Pending'),
                    // style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget buildTopupRetailHistoryItem(TopupRetailHistory history) {
    // bool isDebit = data.debitAmount > 0;
    // String description = data.description;
    // if (data.productName != null &&
    //     data.productDetail != null &&
    //     data.productDetail!.isNotEmpty) {
    //   description =
    //       'Pembelian ${data.productName!.trim()} ke ${data.productDetail!.trim()}';
    // } else if (data.productName != null) {
    //   description = '${data.productName!.trim()}';
    // }
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
      // color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                formatDate(history.created_at),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                formatNumber(history.nominal),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  history.isSuccess
                      ? history.sn!
                      : history.isFailed ? 'Gagal'
                        : history.isExpired ? 'Kadaluarsa' : 'Pending',
                  // style: Theme.of(context).textTheme.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Divider(),
        ],
      ),
    );
  }

  void openFilterDate() async {
    var range = await dateRangeDialog(context,
        initial: dateRange, firstDate: firstDate);
    if (range != null) {
      debugPrint('Date range $range');
      setState(() {
        dateRange = range;
      });
      initDB();
    }
  }

  void onMetodeChange(String? metode) {
    if (metode != null) {
      setState(() {
        selectedMetode = metode;
      });

      if (metode == 'TIKET') {
        pageController.jumpToPage(0);
      } else {
        pageController.jumpToPage(1);
      }
    }
  }

  Widget buildTopupHistoryItems(BuildContext context) {
    if (isLoading && itemsTopup.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: itemsTopup.isEmpty
          ? const Center(
              child: Text('Tidak ada data'),
            )
          : ListView.builder(
              itemCount: itemsTopup.length,
              itemBuilder: (context, index) {
                return buildTopupHistoryItem(itemsTopup[index]);
              },
            ),
    );
  }

  Widget buildTopupRetailHistoryItems(BuildContext context) {
    if (isLoading && itemsTopupRetail.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: itemsTopupRetail.isEmpty
          ? const Center(
        child: Text('Tidak ada data'),
      )
          : ListView.builder(
        itemCount: itemsTopupRetail.length,
        itemBuilder: (context, index) {
          return buildTopupRetailHistoryItem(itemsTopupRetail[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar2(
        title: widget.title,
      ),
      backgroundColor: AppColors.white1,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(padding: const EdgeInsets.all(10), child: const CoinCard()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Radio<String>(
                    onChanged: onMetodeChange,
                    groupValue: selectedMetode,
                    value: 'TIKET',
                    activeColor: Colors.blueAccent,
                  ),
                  GestureDetector(
                    onTap: () {
                      onMetodeChange('TIKET');
                    },
                    child: const Text("Tiket"),
                  ),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    onChanged: onMetodeChange,
                    groupValue: selectedMetode,
                    value: 'TOPUP',
                    activeColor: Colors.blueAccent,
                  ),
                  GestureDetector(
                    onTap: () {
                      onMetodeChange('TOPUP');
                    },
                    child: const Text('Alfamart/Indomaret'),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (value) {
                  if (value == 0) {
                    onMetodeChange('TIKET');
                  } else if (value == 1) {
                    onMetodeChange('TOPUP');
                  }
                },
                children: [
                  buildTopupHistoryItems(context),
                  buildTopupRetailHistoryItems(context),
                ],
              ),
          )
        ],
      ),
    );
  }
}
