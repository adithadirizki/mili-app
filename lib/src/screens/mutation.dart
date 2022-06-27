import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/mutation.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/balance_card.dart';
import 'package:miliv2/src/widgets/balance_credit_card.dart';
import 'package:miliv2/src/widgets/wallet_card.dart';

enum historyAction {
  toggleFavorite,
  showDetail,
  print,
  contactCS,
}

class _WalletMutation {
  int id = 0;
  DateTime transactionDate = DateTime.now();
  String type = '';
  String code = '';
  String desc = '';
  String source = '';
  String sourceName = '';
  double credit = 0;
  double debit = 0;
}

class MutationScreen extends StatefulWidget {
  const MutationScreen({Key? key}) : super(key: key);

  @override
  _MutationScreenState createState() => _MutationScreenState();
}

class _MutationScreenState extends State<MutationScreen> {
  final formKey = GlobalKey<FormState>();
  List<BalanceMutation> balanceHistory = [];
  List<CreditMutation> creditHistory = [];
  final TextEditingController textAmountController = TextEditingController();
  bool isLoading = true;

  late DateTime firstDate;
  late DateTimeRange dateRange;

  List<_WalletMutation> walletHistory = [];

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    firstDate = DateTime(now.year, now.month - 6);
    dateRange = DateTimeRange(
        start: now.subtract(const Duration(hours: 24 * 28)), end: now);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initDB();
    });
  }

  FutureOr<void> _handleError(Object e) {
    setState(() {
      isLoading = false;
    });
    snackBarDialog(context, e.toString());
  }

  Future<void> initDB() async {
    setState(() {
      isLoading = true;
    });

    await Api.walletHistory(dateRange.start, dateRange.end).then((resp) {
      debugPrint('Wallet history ${resp.body}');
      Map<String, dynamic> bodyMap =
          json.decode(resp.body) as Map<String, dynamic>;
      walletHistory = (bodyMap['data'] as List<dynamic>)
          .map((dynamic data) => _WalletMutation()
            ..id = (data['id'] as int)
            ..transactionDate =
                DateTime.parse(data['transactionDate'] as String)
            ..type = (data['type'] as String)
            ..code = (data['code'] as String)
            ..desc = (data['desc'] as String)
            ..credit = (data['credit'] as int).toDouble()
            ..debit = (data['debit'] as int).toDouble()
            ..source = (data['source'] as String)
            ..sourceName = (data['sourceName'] as String))
          .toList();
      walletHistory.sort((a, b) {
        return (a.transactionDate.isBefore(b.transactionDate) ? 1 : -1);
      });
      setState(() {});
    }).catchError(_handleError);
    await AppDB.syncBalanceMutation();
    await AppDB.syncCreditMutation();

    {
      Condition<BalanceMutation> filterDate = BalanceMutation_.mutationDate
          .greaterOrEqual(dateRange.start.millisecondsSinceEpoch)
          .and(BalanceMutation_.mutationDate.lessOrEqual(dateRange.end
              .add(const Duration(hours: 24))
              .millisecondsSinceEpoch));

      Condition<BalanceMutation> filterUser =
          BalanceMutation_.userId.equals(userBalanceState.userId);

      final db = AppDB.balanceMutationDB;
      QueryBuilder<BalanceMutation> query = db.query(filterDate.and(filterUser))
        ..order(BalanceMutation_.mutationDate, flags: 1);
      balanceHistory = query.build().find();
    }

    {
      Condition<CreditMutation> filterDate = CreditMutation_.mutationDate
          .greaterOrEqual(dateRange.start.millisecondsSinceEpoch)
          .and(CreditMutation_.mutationDate.lessOrEqual(dateRange.end
              .add(const Duration(hours: 24))
              .millisecondsSinceEpoch));

      Condition<CreditMutation> filterUser =
          CreditMutation_.userId.equals(userBalanceState.userId);

      final db = AppDB.creditMutationDB;
      QueryBuilder<CreditMutation> query = db.query(filterDate.and(filterUser))
        ..order(CreditMutation_.mutationDate, flags: 1);
      creditHistory = query.build().find();
    }

    debugPrint('InitDB BalanceMutation ${balanceHistory.length}');
    debugPrint('InitDB CreditMutation ${creditHistory.length}');

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onRefresh() {
    return initDB();
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

  PageController pc = PageController(viewportFraction: 0.9, initialPage: 0);
  PageController pc2 = PageController(viewportFraction: 1, initialPage: 0);

  Widget buildTop(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 10, top: 10),
      child: PageView(
        controller: pc,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        onPageChanged: (page) {
          pc2.jumpToPage(page);
        },
        key: const ValueKey('pagemode'),
        children: [
          // Disable main balance for now
          // Container(
          //   margin: const EdgeInsets.only(right: 10),
          //   width: double.infinity,
          //   // color: Colors.red,
          //   child: const BalanceCard(),
          // ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: double.infinity,
            // color: Colors.red,
            child: const WalletCard(),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            width: double.infinity,
            // color: Colors.blue,
            child: const BalanceCreditCard(),
          ),
        ],
      ),
    );
  }

  Widget balanceItem(BalanceMutation data) {
    bool isDebit = data.debitAmount > 0;
    String description = data.description;
    if (data.productName != null &&
        data.productDetail != null &&
        data.productDetail!.isNotEmpty) {
      description =
          'Pembelian ${data.productName!.trim()} ke ${data.productDetail!.trim()}';
    } else if (data.productName != null) {
      description = '${data.productName!.trim()}';
    }
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
      // color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                formatDate(data.mutationDate),
                style: Theme.of(context).textTheme.caption,
              ),
              const Spacer(),
              Text(
                '${formatNumber(data.startBalance)} ${isDebit ? '-' : '+'} ',
                style: Theme.of(context).textTheme.caption,
              ),
              Text(
                isDebit
                    ? formatNumber(data.debitAmount)
                    : formatNumber(data.creditAmount),
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: isDebit ? Colors.redAccent : Colors.blueAccent),
              ),
              Text(
                ' = ${formatNumber(data.endBalance)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  description,
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

  Widget creditItem(CreditMutation data) {
    bool isDebit = data.debitAmount > 0;
    String description = data.description;
    if (data.productName != null &&
        data.productDetail != null &&
        data.productDetail!.isNotEmpty) {
      description =
          'Pembelian ${data.productName!.trim()} ke ${data.productDetail!.trim()}';
    } else if (data.productName != null) {
      description = '${data.productName!.trim()}';
    }
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
      // color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                formatDate(data.mutationDate),
                style: Theme.of(context).textTheme.caption,
              ),
              const Spacer(),
              Text(
                '${formatNumber(data.startBalance)} ${isDebit ? '-' : '+'} ',
                style: Theme.of(context).textTheme.caption,
              ),
              Text(
                isDebit
                    ? formatNumber(data.debitAmount)
                    : formatNumber(data.creditAmount),
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: isDebit ? Colors.redAccent : Colors.blueAccent),
              ),
              Text(
                ' = ${formatNumber(data.endBalance)}',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  description,
                  // style: Theme.of(context).textTheme.bodySmall,
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

  Widget walletItem(_WalletMutation data) {
    bool isDebit = data.debit > 0;
    String description = data.desc;
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
      // color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                formatDate(data.transactionDate),
                style: Theme.of(context).textTheme.caption,
              ),
              const Spacer(),
              // Text(
              //   '${formatNumber(data.startBalance)} ${isDebit ? '-' : '+'} ',
              //   style: Theme.of(context).textTheme.caption,
              // ),
              Text(
                isDebit ? formatNumber(data.debit) : formatNumber(data.credit),
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: isDebit ? Colors.redAccent : Colors.blueAccent),
              ),
              // Text(
              //   ' = ${formatNumber(data.endBalance)}',
              //   style: Theme.of(context).textTheme.caption,
              // ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  data.type.toUpperCase() +
                      '\n' +
                      description
                      // '\n' +
                      // data.source +
                      // ' - ' +
                      // data.sourceName,
                  // style: Theme.of(context).textTheme.bodySmall,
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

  Widget buildItems(BuildContext context) {
    if (isLoading && balanceHistory.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: PageView(
        controller: pc2,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        onPageChanged: (page) {
          pc.jumpToPage(page);
        },
        children: [
          // Disable main balance for now
          // balanceHistory.isEmpty
          //     ? const Center(
          //         child: Text('Tidak ada data'),
          //       )
          //     : ListView.builder(
          //         key: const PageStorageKey<String>('listMutation'),
          //         itemCount: balanceHistory.length,
          //         itemBuilder: (context, index) {
          //           return balanceItem(balanceHistory[index]);
          //         },
          //       ),
          walletHistory.isEmpty
              ? const Center(
                  child: Text('Tidak ada data'),
                )
              : ListView.builder(
                  key: const PageStorageKey<String>('listMutationWallet'),
                  itemCount: walletHistory.length,
                  itemBuilder: (context, index) {
                    return walletItem(walletHistory[index]);
                  },
                ),
          creditHistory.isEmpty
              ? const Center(
                  child: Text('Tidak ada data'),
                )
              : ListView.builder(
                  key: const PageStorageKey<String>('listMutationCredit'),
                  itemCount: creditHistory.length,
                  itemBuilder: (context, index) {
                    return creditItem(creditHistory[index]);
                  },
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: 'Mutasi Saldo',
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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTop(context),
          Flexible(
            flex: 1,
            child: Card(
              // color: Colors.white,
              child: buildItems(context),
            ),
          ),
        ],
      ),
    );
  }
}
