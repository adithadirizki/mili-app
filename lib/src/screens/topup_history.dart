import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/topup.dart';
import 'package:miliv2/src/models/topup_retail.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/images.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

enum historyAction {
  toggleFavorite,
  showDetail,
  print,
  contactCS,
}

class TopupHistoryScreen extends StatefulWidget {
  final int? openDetail;
  final String? metode;

  const TopupHistoryScreen({Key? key, this.openDetail, this.metode}) : super(key: key);

  @override
  _TopupHistoryScreenState createState() => _TopupHistoryScreenState();
}

class _TopupHistoryScreenState extends State<TopupHistoryScreen> {
  final formKey = GlobalKey<FormState>();
  PageController pageController = PageController(initialPage: 0);
  List<TopupHistory> itemsTopup = [];
  List<TopupRetailHistory> itemsTopupRetail = [];
  final TextEditingController textAmountController = TextEditingController();
  bool isLoading = true;
  String selectedMetode = 'TIKET';

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

    if (widget.metode == "TOPUP") {
      selectedMetode = "TOPUP";
      pageController = PageController(initialPage: 1);
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await initDB();

      if (widget.openDetail != null && widget.metode != null) {
        if (widget.metode == 'TIKET') {
          var idx = itemsTopup
              .indexWhere((element) => element.id == widget.openDetail);
          if (idx >= 0) {
            detailTopup(itemsTopup[idx]);
          }
        } else if (widget.metode == 'TOPUP') {
          var idx = itemsTopupRetail
              .indexWhere((element) => element.id == widget.openDetail);
          if (idx >= 0) {
            detailTopupRetail(itemsTopupRetail[idx]);
          }
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

  // Tiket transfer bank
  void detailTopup(TopupHistory history) {
    infoDialog(context, title: 'Detail Transaksi', msg: history.notes);
  }

  // Topup Alfamart/Indomaret
  void detailTopupRetail(TopupRetailHistory history) {
    infoTopupRetail(context, history: history);
  }

  void copy(TopupHistory history) {
    Clipboard.setData(ClipboardData(text: history.amount.toString()));
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

  // Tiket transfer bank
  Widget buildTopupHistoryItem(TopupHistory history) {
    var timeLeft =
    history.transactionDate.add(const Duration(hours: 3)).difference(now);
    return Card(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatNumber(history.amount),
                      // style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                    ),
                    Text(
                      formatDate(history.transactionDate),
                      style: Theme.of(context).textTheme.caption!.copyWith(),
                    ),
                  ],
                ),
                history.isPending
                    ? IconButton(
                        padding: const EdgeInsets.all(0),
                        // iconSize: 30,
                        // splashRadius: 30,
                        icon: const Icon(
                          Icons.copy_rounded,
                          color: Colors.grey,
                          size: 22,
                        ),
                        onPressed: () {
                          copy(history);
                        },
                      )
                    : const SizedBox(),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      // iconSize: 30,
                      // splashRadius: 30,
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.grey,
                        size: 22,
                      ),
                      onPressed: () {
                        detailTopup(history);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: history.isSuccess
                            ? Colors.greenAccent
                            : history.isFailed
                                ? Colors.redAccent
                                : Colors.yellow,
                        borderRadius:
                            const BorderRadius.all(Radius.elliptical(15, 15)),
                      ),
                      child: Text(
                        history.isSuccess
                            ? 'Berhasil'
                            : history.isFailed
                                ? 'Dibatalkan'
                                : history.isPending
                                    ? 'Menunggu Pembayaran'
                                    : history.status.toString(),
                        // style: const TextStyle(
                        //   fontSize: 12,
                        //   color: Colors.white,
                        // ),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    history.isPending
                        ? Text(
                            'Waktu bayar ${printDuration(timeLeft)}',
                          )
                        : const SizedBox(),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   mainAxisSize: MainAxisSize.max,
                    //   children: [
                    //     Text(
                    //       formatNumber(item.amount),
                    //       style: Theme.of(context)
                    //           .textTheme
                    //           .bodyText1!
                    //           .copyWith(fontWeight: FontWeight.bold),
                    //     ),
                    //     const SizedBox(width: 10),
                    //   ],
                    // ),
                    // Text(
                    //   item.status.toString(),
                    //   style: Theme.of(context).textTheme.bodyText1!.copyWith(),
                    // ),
                  ],
                ),
                history.isPending
                    ? AppButton(
                        'Batalkan',
                        history.isPending
                            ? () {
                                cancelTicket(history);
                              }
                            : null,
                        size: const Size(80, 30),
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Topup Alfamart/Indomaret
  Widget buildTopupRetailHistoryItem(TopupRetailHistory history) {
    var timeLeft =
    history.created_at.add(const Duration(hours: 24)).difference(now);
    return Card(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatNumber(history.nominal),
                    ),
                    Text(
                      formatDate(history.created_at),
                      style: Theme.of(context).textTheme.caption!.copyWith(),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.grey,
                        size: 22,
                      ),
                      onPressed: () {
                        detailTopupRetail(history);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: history.isSuccess
                            ? Colors.greenAccent
                            : history.isFailed
                            ? Colors.redAccent
                            : history.isExpired
                            ? Colors.redAccent
                            : Colors.yellow,
                        borderRadius:
                        const BorderRadius.all(Radius.elliptical(15, 15)),
                      ),
                      child: Text(
                        history.isSuccess
                            ? 'Berhasil'
                            : history.isFailed
                            ? 'Gagal'
                            : history.isPending
                            ? 'Menunggu Pembayaran'
                            : history.isExpired
                            ? 'Kadaluarsa'
                            : history.status.toString(),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    history.isPending
                        ? Text(
                      'Waktu bayar ${printDuration(timeLeft)}',
                    )
                        : const SizedBox(),
                  ],
                ),
                Image(
                  image: history.channel == "ALFAMART" ? AppImages.alfamart : AppImages.indormaret,
                  width: 45,
                )
                // Text(history.channel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tiket transfer bank
  Widget buildItemsTopupHistory(BuildContext context) {
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

  // Topup Alfamart/Indomaret
  Widget buildItemsTopupRetailHistory(BuildContext context) {
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
      appBar: SimpleAppBar(
        title: 'Riwayat Beli Koin',
        elevation: 0,
        actions: <Widget>[
          IconButton(
            onPressed: openFilterDate,
            icon: const Image(
              image: AppImages.calendar,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${formatDate(dateRange.start, format: 'd MMM')} - ${formatDate(dateRange.end, format: 'd MMM')}',
              // style: Theme.of(context).textTheme.button,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: AppColors.black1),
            ),
            const SizedBox(height: 10,),
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
            Expanded(child: PageView(
              controller: pageController,
              onPageChanged: (value) {
                if (value == 0) {
                  onMetodeChange('TIKET');
                } else if (value == 1) {
                  onMetodeChange('TOPUP');
                }
              },
              children: [
                buildItemsTopupHistory(context),
                buildItemsTopupRetailHistory(context),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
