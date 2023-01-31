import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/data/transaction.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/purchase.dart';
import 'package:miliv2/src/screens/customer_service.dart';
import 'package:miliv2/src/screens/print.dart';
import 'package:miliv2/src/services/printer.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/purchase_history_item.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  final String title;

  const HistoryScreen({Key? key, this.title = 'Riwayat Transaksi'})
      : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<PurchaseHistory> items = [];
  bool isLoading = true;

  final formKey = GlobalKey<FormState>();
  final favoriteNameController = TextEditingController();

  late DateTime firstDate;
  late DateTimeRange dateRange;

  late ScrollController scrollController;
  int currentPage = 0;
  int itemPerPage = 10;
  bool hasMore = false;

  int successTotal = 0;
  int failedTotal = 0;
  int pendingTotal = 0;
  double totalTransaction = 0;

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    firstDate = DateTime(now.year, now.month - 6);
    dateRange = DateTimeRange(
        start: now.subtract(const Duration(hours: 24 * 28)), end: now);
    scrollController = ScrollController()..addListener(scrollListener);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initDB(sync: true);
      // Refresh DB
      transactionState.addListener(() {
        debugPrint('Refetch History');
        initDB(sync: true);
      });
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() {
    var triggerFetchMoreSize = 0.9 * scrollController.position.maxScrollExtent;

    if (scrollController.position.pixels > triggerFetchMoreSize &&
        !isLoading &&
        scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
      if (hasMore) {
        initDB();
      }
    }
  }

  Future<void> initDB({bool sync = false}) async {
    setState(() {
      isLoading = true;
    });

    if (sync) {
      await AppDB.syncHistory();
      currentPage = 0;
      items = [];
      await countSummary();
    }

    Condition<PurchaseHistory> filterDate = PurchaseHistory_.transactionDate
        .greaterOrEqual(dateRange.start.millisecondsSinceEpoch)
        .and(PurchaseHistory_.transactionDate.lessOrEqual(dateRange.end
            .add(const Duration(hours: 24))
            .millisecondsSinceEpoch));

    Condition<PurchaseHistory> filterUser =
        PurchaseHistory_.userId.equals(userBalanceState.userId);

    final purchaseHistoryDB = AppDB.purchaseHistoryDB;
    QueryBuilder<PurchaseHistory> qb = purchaseHistoryDB
        .query(filterDate.and(filterUser))
      ..order(PurchaseHistory_.transactionDate, flags: Order.descending);

    var query = qb.build()
      ..offset = itemPerPage * currentPage
      ..limit = itemPerPage;

    var records = query.find();
    if (records.length >= itemPerPage) {
      currentPage++;
      hasMore = true;
    } else {
      hasMore = false;
    }
    items.addAll(records);

    query.close();

    debugPrint(
        'InitDB History $currentPage x ${records.length} x ${items.length}');

    setState(() {
      isLoading = false;
    });
  }

  Future<void> countSummary({bool sync = false}) async {
    Condition<PurchaseHistory> filterDate = PurchaseHistory_.transactionDate
        .greaterOrEqual(dateRange.start.millisecondsSinceEpoch)
        .and(PurchaseHistory_.transactionDate.lessOrEqual(dateRange.end
            .add(const Duration(hours: 24))
            .millisecondsSinceEpoch));

    Condition<PurchaseHistory> filterUser =
        PurchaseHistory_.userId.equals(userBalanceState.userId);

    final purchaseHistoryDB = AppDB.purchaseHistoryDB;
    QueryBuilder<PurchaseHistory> qb =
        purchaseHistoryDB.query(filterDate.and(filterUser));

    var query = qb.build();
    List<PurchaseHistory> records = query.find();

    setState(() {
      successTotal = records.where((element) => element.isSuccess).length;
      failedTotal = records.where((element) => element.isFailed).length;
      pendingTotal = records.where((element) => element.isPending).length;
      totalTransaction = records.fold(
          0,
          (previousValue, element) =>
              previousValue + (element.isSuccess ? element.price : 0));
    });
  }

  Future<void> onRefresh() {
    return initDB(sync: true);
  }

  FutureOr<void> _handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  Future<void> showFavoriteDialog(PurchaseHistory history) async {
    showDialog<Widget>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          // title: const Text('Nama'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: favoriteNameController,
                    autofocus: true,
                    decoration: generateInputDecoration(
                      label: 'Nama',
                      hint: '',
                      // errorMsg: !_valid ? AppLabel.errorRequired : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan Nama';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                favoriteNameController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Batal',
                // style: Theme.of(context).textTheme.button,
              ),
            ),
            TextButton(
              onPressed: () async {
                var success = await saveFavorite(history);
                if (success) {
                  await Navigator.of(context).maybePop();
                }
              },
              child: const Text(
                'Simpan',
                // style: Theme.of(context).textTheme.button,
              ),
            )
          ],
        );
      },
    );
  }

  Future<bool> saveFavorite(PurchaseHistory history) async {
    if (formKey.currentState!.validate()) {
      await Api.addFavorite(favoriteNameController.text, history.productCode,
              history.destination)
          .then((response) {
        if (response.statusCode == 200) {
          snackBarDialog(context, 'Berhasil menyimpan nomor');
        }
      }).catchError(_handleError);
      favoriteNameController.clear();
      return true;
    }
    return false;
  }

  VoidCallback execAction(historyAction action, PurchaseHistory history) {
    void print(PurchaseHistoryDetailResponse invoice) {
      AppPrinter.printPurchaseHistory(invoice, context: context);
    }

    return () async {
      if (action == historyAction.purchase) {
        openPurchaseScreen(context,
            productCode: history.productCode,
            groupName: history.groupName,
            destination: history.destination);
        return;
      }
      await popScreen(context);
      if (action == historyAction.addFavorite) {
        showFavoriteDialog(history);
      } else if (action == historyAction.showDetail) {
        await Api.getPurchaseDetail(history.serverId).then((response) {
          Map<String, dynamic> bodyMap =
              json.decode(response.body) as Map<String, dynamic>;
          var detail = PurchaseHistoryDetailResponse.fromJson(bodyMap);
          infoDialog(
            context,
            title: 'Detail Transaksi',
            msg: detail.invoice,
          );
        }).catchError(_handleError);
      } else if (action == historyAction.showInvoice) {
        await Api.getPurchaseDetail(history.serverId).then((response) {
          Map<String, dynamic> bodyMap =
              json.decode(response.body) as Map<String, dynamic>;
          var detail = PurchaseHistoryDetailResponse.fromJson(bodyMap);
          // confirmDialog(
          //   context,
          //   title: 'Detail Transaksi',
          //   msg: detail.invoice + '\n\nCetak struk ?',
          //   confirmAction: () {
          //     print(detail);
          //   },
          // );

          pushScreen(context, (ctx) {
            return PrintScreen(history: detail);
          });
        }).catchError(_handleError);
      } else if (action == historyAction.print) {
        await Api.getPurchaseDetail(history.serverId).then((response) {
          Map<String, dynamic> bodyMap =
              json.decode(response.body) as Map<String, dynamic>;
          var struct = PurchaseHistoryDetailResponse.fromJson(bodyMap);

          pushScreen(context, (ctx) {
            return PrintScreen(history: struct);
          });
        }).catchError(_handleError);
      } else if (action == historyAction.contactCS) {
        var message =
            'Transaksi *${history.productName}* ${history.destination} ${history.statusDesc} (${formatDate(history.transactionDate)})';
        pushScreen(
          context,
          (_) => CustomerServiceScreen(message: message),
        );
      } else if (action == historyAction.share) {
        final box = context.findRenderObject() as RenderBox?;
        await Api.getPurchaseDetail(history.serverId).then((response) {
          Map<String, dynamic> bodyMap =
              json.decode(response.body) as Map<String, dynamic>;
          var struct = PurchaseHistoryDetailResponse.fromJson(bodyMap);
          Share.share(struct.invoice,
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
        }).catchError(_handleError);
      }
    };
  }

  VoidCallback openPopup(PurchaseHistory history) {
    List<ListTile> menu = List.empty(growable: true);
    if (!history.isPending) {
      if (history.isFailed) {
        menu.addAll([
          ListTile(
            // contentPadding: EdgeInsets.all(0),
            title: const Text(
              'Detail',
              // style: Theme.of(context).textTheme.bodySmall,
            ),
            leading: const Icon(Icons.info_outline_rounded),
            onTap: execAction(historyAction.showDetail, history),
          ),
        ]);
      } else {
        menu.addAll([
          ListTile(
            // contentPadding: EdgeInsets.all(0),
            title: const Text(
              'Struk',
              // style: Theme.of(context).textTheme.bodySmall,
            ),
            leading: const Icon(Icons.info_outline_rounded),
            onTap: execAction(historyAction.showInvoice, history),
          ),
          // ListTile(
          //   // contentPadding: EdgeInsets.all(0),
          //   title: const Text(
          //     'Print',
          //     // style: Theme.of(context).textTheme.bodySmall,
          //   ),
          //   leading: const Icon(Icons.print_outlined),
          //   onTap: execAction(historyAction.print, history),
          // ),
          // ListTile(
          //   // contentPadding: EdgeInsets.all(0),
          //   title: const Text(
          //     'Share',
          //     // style: Theme.of(context).textTheme.bodySmall,
          //   ),
          //   leading: const Icon(Icons.share_rounded),
          //   onTap: execAction(historyAction.share, history),
          // ),
        ]);
      }
    }
    menu.addAll([
      ListTile(
        // contentPadding: EdgeInsets.all(0),
        title: const Text(
          'Hubungi CS',
          // style: Theme.of(context).textTheme.bodySmall,
        ),
        leading: const Icon(Icons.messenger_outline_rounded),
        onTap: execAction(historyAction.contactCS, history),
      ),
      ListTile(
        // contentPadding: EdgeInsets.all(0),
        title: const Text(
          'Simpan Nomor',
          // style: Theme.of(context).textTheme.bodySmall,
        ),
        leading: const Icon(Icons.favorite_border_rounded),
        onTap: execAction(historyAction.addFavorite, history),
      ),
    ]);
    return () {
      bottomSheetDialog<void>(
        context: context,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: menu,
        ),
      );
    };
  }

  void openFilterDate() async {
    var range = await dateRangeDialog(context,
        initial: dateRange, firstDate: firstDate);
    if (range != null) {
      debugPrint('Date range $range');
      setState(() {
        dateRange = range;
      });
      initDB(sync: true);
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
          : Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    key: const PageStorageKey<String>('listHistory'),
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return PurchaseHistoryItem(
                        key: Key(items[index].id.toString()),
                        history: items[index],
                        execAction: execAction,
                        openPopup: openPopup,
                      );
                    },
                  ),
                ),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const SizedBox()
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: widget.title,
        elevation: 0,
        actions: <Widget>[
          // TextButton(
          //   child: Text(
          //     '${formatDate(dateRange.start, format: 'd MMM')} - ${formatDate(dateRange.end, format: 'd MMM')}',
          //     // style: Theme.of(context).textTheme.button,
          //     style: Theme.of(context)
          //         .textTheme
          //         .bodySmall
          //         ?.copyWith(color: AppColors.black1),
          //   ),
          //   onPressed: openFilterDate,
          // ),
          IconButton(
            onPressed: openFilterDate,
            icon: const Image(
              image: AppImages.calendar,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 0, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: AppColors.white1,
            ),
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
                const SizedBox(height: 20),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 20,
                      child: Column(
                        children: [
                          const Text('Sukses'),
                          Text(
                            formatNumber(successTotal.toDouble()),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 20,
                      child: Column(
                        children: [
                          const Text('Gagal'),
                          Text(
                            formatNumber(failedTotal.toDouble()),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 20,
                      child: Column(
                        children: [
                          const Text('Diproses'),
                          Text(
                            formatNumber(pendingTotal.toDouble()),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        textBaseline: TextBaseline.ideographic),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: FittedBox(
                                  child: Text(
                                    formatNumber(totalTransaction),
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: buildItems(context),
            ),
          ),
        ],
      ),
    );
  }
}
