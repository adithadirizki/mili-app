import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/downline.dart';
import 'package:miliv2/src/consts/consts.dart';
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
  // true = asc, false = desc
  var sort = ['balance', 'desc'];

  bool openSearch = false;
  bool openSort = false;
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
      'sort': json.encode({sort[0]: sort[1]}),
      'limit': '1000'
    };

    debugPrint('getDownline ${json.encode(params)}');

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
      'sort': json.encode({sort[0]: sort[1]}),
      'limit': '1000'
    };

    if (value.isNotEmpty) {
      params['filter'] = json.encode(<String, dynamic>{'nama': 'like|%$value%'});
    }

    await Api.getDownline(params: params)
        .then(handleDownlineList)
        .catchError(handleError);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onSort(String field, String direction) async {
    setState(() {
      isLoading = true;
      sort = [field, direction];
    });

    Map<String, String> params = {
      'sort': json.encode({sort[0]: sort[1]}),
      'limit': '1000'
    };

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

  void openFilterSort() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: 230,
            padding: EdgeInsets.all(10),
            color: AppColors.white1,
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    const field = 'balance';
                    var direction = 'desc';
                    if (sort[0] == field) {
                      direction = sort[1] == 'asc' ? 'desc' : 'asc';
                    }
                    onSort(field, direction);
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saldo Utama', style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue6)),
                      Transform.scale(
                        scaleY: (sort[0] == 'balance'
                            ? (sort[1] == 'asc' ? -1 : 1)
                            : 0),
                        child: const Image(image: AppImages.sort, width: 25),
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    const field = 'balance_credit';
                    var direction = 'desc';
                    if (sort[0] == field) {
                      direction = sort[1] == 'asc' ? 'desc' : 'asc';
                    }
                    onSort(field, direction);
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saldo Kredit', style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue6)),
                      Transform.scale(
                        scaleY: (sort[0] == 'balance_credit'
                            ? (sort[1] == 'asc' ? -1 : 1)
                            : 0),
                          child: const Image(image: AppImages.sort, width: 25)
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    const field = 'hit';
                    var direction = 'desc';
                    if (sort[0] == field) {
                      direction = sort[1] == 'asc' ? 'desc' : 'asc';
                    }
                    onSort(field, direction);
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hit', style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue6)),
                      Transform.scale(
                        scaleY: (sort[0] == 'hit'
                            ? (sort[1] == 'asc' ? -1 : 1)
                            : 0),
                          child: const Image(image: AppImages.sort, width: 25)
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    const field = 'last_active';
                    var direction = 'desc';
                    if (sort[0] == field) {
                      direction = sort[1] == 'asc' ? 'desc' : 'asc';
                    }
                    onSort(field, direction);
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Terakhir Aktif', style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue6)),
                      Transform.scale(
                        scaleY: (sort[0] == 'last_active'
                            ? (sort[1] == 'asc' ? -1 : 1)
                            : 0),
                          child: const Image(image: AppImages.sort, width: 25)
                      )
                    ],
                  ),
                ),
              ],
            ));
      },
    );
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
                          paymentMethodLabel[PaymentMethod.mainBalance]!,
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
                          paymentMethodLabel[PaymentMethod.creditBalance]!,
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
          : const Padding(padding: EdgeInsets.only(top: 20), child: Text('- Tidak ada data -')),
    );
  }

  Widget buildSummary(BuildContext context) {
    return Container(
      // height: 200,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.elliptical(20, 20)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.gradientBlue2, AppColors.gradientBlue1],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0.0, 4.0), //(x,y)
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding:
            const EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 15),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.elliptical(18, 18)),
            ),
            child: Text('Statistik Bulanan', style: Theme.of(context).textTheme.headline6?.copyWith(color: AppColors.white1, fontWeight: FontWeight.bold),),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(width: 0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transaksi', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white1)),
                  Text(formatNumber(totalTrx), style: Theme.of(context).textTheme.headline6?.copyWith(color: AppColors.white1, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white1)),
                  Text(formatNumber(totalDownline), style: Theme.of(context).textTheme.headline6?.copyWith(color: AppColors.white1, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Komisi', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white1)),
                  Text(formatNumber(totalBonus), style: Theme.of(context).textTheme.headline6?.copyWith(color: AppColors.white1, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 0),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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
      appBar: SimpleAppBar(
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
                      color: AppColors.blue6,
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
                IconButton(
                  onPressed: toggleSearch,
                  icon: const Image(
                    image: AppImages.search,
                  ),
                ),
                IconButton(
                  onPressed: openFilterSort,
                  icon: const Image(
                    image: AppImages.sort,
                  ),
                ),
              ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: AppColors.white1),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(
                    '${formatDate(dateRange.start, format: 'd MMM')} - ${formatDate(dateRange.end, format: 'd MMM')}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
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
            const SizedBox(height: 10),
            buildSummary(context),
            const SizedBox(height: 20),
            Text('Daftar Downline', style: Theme.of(context).textTheme.headline6?.copyWith(color: AppColors.black1, fontWeight: FontWeight.normal)),
            FlexBoxGray(
              padding: const EdgeInsets.all(10),
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
        backgroundColor: const Color(0xff1c96d2),
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
