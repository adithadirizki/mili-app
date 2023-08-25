import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/downline.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/screens/downline_update.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/screen.dart';

class DownlineDetailScreen extends StatefulWidget {
  final DownlineResponse downline;

  DownlineDetailScreen({Key? key, required this.downline}) : super(key: key);

  @override
  _DownlineDetailScreenState createState() => _DownlineDetailScreenState();
}

class _DownlineDetailScreenState extends State<DownlineDetailScreen> {
  bool isLoading = true;
  List<PurchaseHistoryResponse> items = [];
  double totalAmount = 0;
  double totalTrx = 0;
  double totalTrxSuccess = 0;
  double totalTrxFailed = 0;
  double totalBonus = 0;

  late DateTime firstDate;
  late DateTimeRange dateRange;

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

  Future<void> initDB() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> params = {
      'agenid': widget.downline.userId,
      'startDate': formatDate(dateRange.start, format: 'yyyy-MM-dd'),
      'endDate': formatDate(dateRange.end, format: 'yyyy-MM-dd'),
      'sort': json.encode({'tanggal': 'desc'}),
      'limit': '50'
    };
    await Api.getDownlineLastTransaction(params: params)
        .then(handleDownlineTransaction)
        .catchError(handleError);

    Map<String, String> summary = {
      'agenid': widget.downline.userId,
      'startDate': formatDate(dateRange.start, format: 'yyyy-MM-dd'),
      'endDate': formatDate(dateRange.end, format: 'yyyy-MM-dd'),
    };

    await Api.getDownlineSummary(params: summary)
        .then(handleSummary)
        .catchError(handleError);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onRefresh() {
    return initDB();
  }

  void handleDownlineTransaction(http.Response response) {
    var status = response.statusCode;
    if (status == 200) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      debugPrint('Last trx ${bodyMap}');
      items = (bodyMap['data'] as List<dynamic>)
          .map((dynamic e) =>
              PurchaseHistoryResponse.fromJson(e as Map<String, dynamic>))
          .toList(growable: true);
      items.sort(
          (a, b) => (a.transactionDate.isAfter(b.transactionDate) ? -1 : 1));
    }
  }

  void handleSummary(http.Response response) {
    var status = response.statusCode;
    if (status == 200) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      totalTrx =
          bodyMap.containsKey('trx') ? (bodyMap['trx']! as int).toDouble() : 0;
      totalTrxSuccess =
      bodyMap.containsKey('summary')
          ? (bodyMap['summary']['trx_success']! as int).toDouble()
          : 0;
      totalTrxFailed =
      bodyMap.containsKey('summary')
          ? (bodyMap['summary']['trx_failed']! as int).toDouble()
          : 0;
      totalAmount = bodyMap.containsKey('total')
          ? (bodyMap['total']! as int).toDouble()
          : 0;
      totalBonus = bodyMap.containsKey('bonus')
          ? (bodyMap['bonus']! as int).toDouble()
          : 0;
    }
  }

  FutureOr<void> handleError(Object e) {
    setState(() {
      isLoading = false;
    });
    snackBarDialog(context, e.toString());
  }

  void openFilterDate() async {
    var range = await dateRangeDialog(context,
        initial: dateRange, firstDate: firstDate);
    if (range != null) {
      debugPrint('Date range $range');

      if (range.end.isBefore(range.start.add(const Duration(days: 30)))) {
        setState(() {
          dateRange = range;
        });
        initDB();
      } else {
        snackBarDialog(context, 'Maksimal 30 hari terakhir.');
      }
    }
  }

  void onEdit() async {
    var completed = await pushScreenWithCallback<bool>(
      context,
      (_) => DownlineUpdateScreen(downline: widget.downline),
    );
  }

  Widget buildHistoryItem(PurchaseHistoryResponse history) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              history.productName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 5),
            Text(
              formatDate(history.transactionDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp ${formatNumber(history.price)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              decoration: BoxDecoration(
                color: history.status == 'FAILED'
                    ? Colors.redAccent
                    : (history.status == 'SUCCESSED'
                      ? Colors.greenAccent
                      : Colors.blueAccent),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text(
                history.status == 'FAILED'
                    ? 'Gagal'
                    : (history.status == 'SUCCESSED'
                      ? 'Berhasil'
                      : 'Refund'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      )
    );
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
      child: items.isNotEmpty
          ? ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return buildHistoryItem(items[index]);
              },
            )
          : const Center(
              child: Image(
                image: AppImages.emptyPlaceholder,
              ),
            ),
    );
  }

  Widget buildInfo(BuildContext context) {
    return Card(
      child: Container(
        // width: double.infinity,
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: widget.downline.getPhotoUrl() == null
                  ? const Image(
                      image: AppImages.photoProfilePlaceholder,
                      width: 50,
                      height: 50,
                    )
                  : FadeInImage(
                      image: NetworkImage(widget.downline.getPhotoUrl()!),
                      placeholder: AppImages.photoProfilePlaceholder,
                      width: 50,
                      height: 50,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return const Image(
                          image: AppImages.photoProfilePlaceholder,
                          width: 50,
                          height: 50,
                        );
                      },
                    ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.downline.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  widget.downline.phoneNumber,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Markup : ${formatNumber(widget.downline.markup)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              padding: const EdgeInsets.all(0),
              // iconSize: 30,
              // splashRadius: 30,
              color: Colors.yellow,
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.grey,
                size: 22,
              ),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummary(BuildContext context) {
    return Card(
      child: Container(
        // width: double.infinity,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Statistik',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  Text(
                    'Berhasil',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(formatNumber(totalTrxSuccess)),
                ]),
                Column(children: [
                  Text(
                    'Gagal',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(formatNumber(totalTrxFailed)),
                ]),
                // Column(children: [
                //   const Text('Jumlah'),
                //   Text(formatNumber(totalAmount)),
                // ]),
                Column(children: [
                  Text(
                    'Komisi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(formatNumber(totalBonus)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar2(
        title: 'Downline',
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
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfo(context),
            buildSummary(context),
            const SizedBox(height: 10),
            Text(
              'Transaksi terakhir',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: const Color(0xFFCBC9C9)),
            ),
            FlexBoxGray(
              margin: const EdgeInsets.only(top: 10),
              child: buildItems(context),
            ),
          ],
        ),
      ),
    );
  }
}
