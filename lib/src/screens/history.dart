import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/data/transaction.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/purchase.dart';
import 'package:miliv2/src/screens/customer_service.dart';
import 'package:miliv2/src/services/printer.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/purchase_history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    firstDate = DateTime(now.year, now.month - 6);
    dateRange = DateTimeRange(
        start: now.subtract(const Duration(hours: 24 * 28)), end: now);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initDB();
      // Refresh DB
      transactionState.addListener(() {
        debugPrint('Refetch History');
        initDB();
      });
    });
  }

  Future<void> initDB() async {
    setState(() {
      isLoading = true;
    });

    await AppDB.syncHistory();

    Condition<PurchaseHistory> filterDate = PurchaseHistory_.transactionDate
        .greaterOrEqual(dateRange.start.millisecondsSinceEpoch)
        .and(PurchaseHistory_.transactionDate.lessOrEqual(dateRange.end
            .add(const Duration(hours: 24))
            .millisecondsSinceEpoch));

    Condition<PurchaseHistory> filterUser =
        PurchaseHistory_.userId.equals(userBalanceState.userId);

    final purchaseHistoryDB = AppDB.purchaseHistoryDB;
    QueryBuilder<PurchaseHistory> query = purchaseHistoryDB
        .query(filterDate.and(filterUser))
      ..order(PurchaseHistory_.transactionDate, flags: 1);
    items = query.build().find();

    debugPrint('InitDB History ${items.length}');

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
      if (invoice.config == null || true) {
        // FIXME disable printConfig for now
        List<LineText> rows = [];
        rows.add(LineText(
          type: LineText.TYPE_TEXT,
          content: invoice.invoice,
          weight: 0,
          align: LineText.ALIGN_LEFT,
        ));

        AppPrinter.print(rows);
      } else {
        AppPrinter.printConfig(invoice.config!);
      }
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
          confirmDialog(
            context,
            title: 'Detail Transaksi',
            msg: detail.invoice + '\n\nCetak struk ?',
            confirmAction: () {
              print(detail);
            },
          );
        }).catchError(_handleError);
      } else if (action == historyAction.print) {
        await Api.getPurchaseDetail(history.serverId).then((response) {
          Map<String, dynamic> bodyMap =
              json.decode(response.body) as Map<String, dynamic>;
          var struct = PurchaseHistoryDetailResponse.fromJson(bodyMap);
          print(struct);
        }).catchError(_handleError);
      } else if (action == historyAction.contactCS) {
        pushScreen(
          context,
          (_) => const CustomerServiceScreen(),
        );
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
          ListTile(
            // contentPadding: EdgeInsets.all(0),
            title: const Text(
              'Print',
              // style: Theme.of(context).textTheme.bodySmall,
            ),
            leading: const Icon(Icons.print_outlined),
            onTap: execAction(historyAction.print, history),
          ),
        ]);
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
    } else {
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
    }
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
              key: const PageStorageKey<String>('listHistory'),
              itemCount: items.length,
              itemBuilder: (context, index) {
                // return historyItem(items[index]);
                return PurchaseHistoryItem(
                  key: Key(items[index].id.toString()),
                  history: items[index],
                  execAction: execAction,
                  openPopup: openPopup,
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Riwayat Transaksi',
        actions: <Widget>[
          TextButton(
            child: Text(
              '${formatDate(dateRange.start, format: 'd MMM')} - ${formatDate(dateRange.end, format: 'd MMM')}',
              // style: Theme.of(context).textTheme.button,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.black1),
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
  }
}
