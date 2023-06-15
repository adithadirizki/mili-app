import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/downline.dart';
import 'package:miliv2/src/screens/downline_detail.dart';
import 'package:miliv2/src/screens/downline_register.dart';
import 'package:miliv2/src/screens/transfer.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:miliv2/src/widgets/screen.dart';

class DownlineScreen extends StatefulWidget {
  const DownlineScreen({Key? key}) : super(key: key);

  @override
  _DownlineScreenState createState() => _DownlineScreenState();
}

class _DownlineScreenState extends State<DownlineScreen> {
  bool isLoading = true;
  List<DownlineResponse> items = [];
  double totalDownline = 0;
  double totalTrx = 0;
  double totalBonus = 0;

  late DateTime firstDate;
  late DateTimeRange dateRange;

  bool openSearch = false;
  Timer? delayed;

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
      'sort': json.encode({'last_active': 'desc'}),
      'limit': '1000'
    };
    await Api.getDownline(params: params)
        .then(handleDownlineList)
        .catchError(handleError);

    Map<String, String> summary = {
      'startDate': formatDate(dateRange.start, format: 'yyyy-MM-dd'),
      'endDate': formatDate(dateRange.end, format: 'yyyy-MM-dd'),
    };
    debugPrint('getSummary ${summary}');

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

  Future<void> onSearch(String value) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> params = {
      'sort': json.encode({'last_active': 'desc'}),
      'limit': '1000'
    };

    if (value.isNotEmpty) {
      params['filter'] = json.encode(<String, dynamic>{'nama': 'like|$value%'});
    }

    await Api.getDownline(params: params)
        .then(handleDownlineList)
        .catchError(handleError);

    setState(() {
      isLoading = false;
    });
  }

  void handleDownlineList(http.Response response) {
    var status = response.statusCode;
    if (status == 200) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      debugPrint('downline $bodyMap');
      var pagingResponse = PagingResponse.fromJson(bodyMap);
      items = pagingResponse.data
          .map((dynamic e) =>
              DownlineResponse.fromJson(e as Map<String, dynamic>))
          .toList(growable: true);
      totalDownline = pagingResponse.total.toDouble();
    }
  }

  void handleSummary(http.Response response) {
    var status = response.statusCode;
    if (status == 200) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      debugPrint('Summary API ${bodyMap}');
      totalTrx =
          bodyMap.containsKey('trx') ? (bodyMap['trx']! as int).toDouble() : 0;
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

  void onRegisterDownline() async {
    var completed = await pushScreenWithCallback<bool>(
      context,
      (_) => const DownlineRegisterScreen(),
    );
    if (completed == true) {
      initDB();
    }
  }

  VoidCallback onDetail(DownlineResponse downline) {
    return () {
      pushScreen(
        context,
        (_) => DownlineDetailScreen(downline: downline),
      );
    };
  }

  VoidCallback onTransfer(DownlineResponse downline) {
    return () {
      pushScreen(
        context,
        (_) => TransferScreen(
          userId: downline.phoneNumber,
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

  void toggleSearch() async {
    openSearch = !openSearch;
    if (!openSearch) onRefresh();
    setState(() {});
  }

  Widget buildDownlineItem(DownlineResponse downline) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: downline.getPhotoUrl() == null
                      ? const Image(
                          image: AppImages.photoProfilePlaceholder,
                          width: 50,
                          height: 50,
                        )
                      : FadeInImage(
                          image: NetworkImage(downline.getPhotoUrl()!),
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
                      downline.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      downline.phoneNumber,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Aktifitas : ${formatDate(downline.lastActivityDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  padding: const EdgeInsets.all(0),
                  // iconSize: 30,
                  // splashRadius: 30,
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.grey,
                    size: 22,
                  ),
                  onPressed: onDetail(downline),
                ),
              ],
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 60),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Saldo Utama',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    Text(
                      formatNumber(downline.balance),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Saldo Kredit',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    Text(
                      formatNumber(downline.balanceCredit),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                AppButton(
                  'Transfer',
                  onTransfer(downline),
                  size: const Size(80, 30),
                ),
              ],
            ),
          ],
        ),
      ),
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
                return buildDownlineItem(items[index]);
              },
            )
          : const Center(
              child: Image(
                image: AppImages.emptyPlaceholder,
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
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '     Statistik',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Icon(
                  Icons.bar_chart_rounded,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Downline',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      formatNumber(totalDownline),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Transaksi',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      formatNumber(totalTrx),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Komisi',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      formatNumber(totalBonus),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
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
        widget: openSearch
            ? Container(
                alignment: Alignment.centerLeft,
                color: Colors.white,
                child: TextField(
                  onChanged: (value) {
                    if (delayed != null) delayed!.cancel();
                    delayed = Timer(const Duration(milliseconds: 500), () {
                      onSearch(value);
                    });
                  },
                  decoration: generateInputDecoration(
                    hint: 'Cari Downline',
                    suffixIcon: IconButton(
                      color: AppColors.main6,
                      icon: const Icon(Icons.close),
                      onPressed: toggleSearch,
                    ),
                  ),
                ),
              )
            : null,
        actions: openSearch
            ? []
            : <Widget>[
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
                IconButton(
                  onPressed: toggleSearch,
                  icon: const Icon(Icons.search, color: AppColors.main3, size: 32),
                ),
              ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: [
            buildSummary(context),
            FlexBoxGray(
              margin: const EdgeInsets.only(top: 10),
              child: buildItems(context),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        isExtended: false,
        onPressed: onRegisterDownline,
        backgroundColor: AppColors.main2,
        child: Container(
          margin: const EdgeInsets.all(1.0),
          padding: const EdgeInsets.all(12),
          child: const Image(
            image: AppImages.userPlus,
          ),
        ),
        elevation: 4.0,
      ),
    );
  }
}
