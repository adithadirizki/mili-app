import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/topup.dart';
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

  const TopupHistoryScreen({Key? key, this.openDetail}) : super(key: key);

  @override
  _TopupHistoryScreenState createState() => _TopupHistoryScreenState();
}

class _TopupHistoryScreenState extends State<TopupHistoryScreen> {
  final formKey = GlobalKey<FormState>();
  List<TopupHistory> items = [];
  final TextEditingController textAmountController = TextEditingController();
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
        var idx = items
            .indexWhere((element) => element.serverId == widget.openDetail);
        if (idx >= 0) {
          detail(items[idx]);
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

    Condition<TopupHistory> filterDate = TopupHistory_.transactionDate
        .greaterOrEqual(dateRange.start.millisecondsSinceEpoch)
        .and(TopupHistory_.transactionDate.lessOrEqual(dateRange.end
            .add(const Duration(hours: 24))
            .millisecondsSinceEpoch));

    Condition<TopupHistory> filterUser =
        TopupHistory_.userId.equals(userBalanceState.userId);

    final db = AppDB.topupHistoryDB;
    QueryBuilder<TopupHistory> query = db.query(filterDate.and(filterUser))
      ..order(TopupHistory_.transactionDate, flags: 1);
    items = query.build().find();

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

  Widget buildHistoryItem(TopupHistory history) {
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
                        detail(history);
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

  Widget buildItems(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? const Center(
              child: Text('Tidak ada data'),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return buildHistoryItem(items[index]);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Tiket',
        actions: <Widget>[
          TextButton(
            child: Text(
              '${formatDate(dateRange.start, format: 'd MMM')} - ${formatDate(dateRange.end, format: 'd MMM')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: openFilterDate,
          ),
          IconButton(
            onPressed: openFilterDate,
            icon: const Image(
              image: AppImages.calendar,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: buildItems(context),
      ),
    );
    // return Container(
    //   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    //   alignment: Alignment.topLeft,
    //   child: buildItems(context),
    // );
  }
}
