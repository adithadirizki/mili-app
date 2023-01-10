import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/promo.dart';
import 'package:miliv2/src/data/promo.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:url_launcher/url_launcher.dart';

class PromoScreen extends StatefulWidget {
  final String title;

  const PromoScreen({Key? key, this.title = 'Promo'}) : super(key: key);

  @override
  _PromoScreenState createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  // List<PurchaseHistory> items = [];
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

    await promoState.fetchData();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onRefresh() {
    return initDB(sync: true);
  }

  FutureOr<void> _handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  Future<void> showPerformance(PromoResponse promo) async {
    var body = '';
    await Api.promoSummary(promo).then((resp) {
      body = resp.body;
    });
    showDialog<Widget>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          // title: const Text('Nama'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 20.0,
              maxHeight: 200,
              minWidth: 200,
            ),
            child: Html(
              data: body,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                favoriteNameController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Tutup',
                // style: Theme.of(context).textTheme.button,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget item(PromoResponse promo) {
    return Card(
      child: GestureDetector(
        // padding: const EdgeInsets.all(15),
        onTap: (promo.link != null && promo.link!.isNotEmpty)
            ? () async {
                if (await canLaunch(promo.link!)) {
                  await launch(promo.link!);
                } else {
                  snackBarDialog(context, 'Tidak bisa membuka link');
                }
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              child: CachedNetworkImage(
                imageUrl: promo.getImageUrl(),
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                width: double.infinity,
                height: 150,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo.title,
                            // style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Periode ${formatDate(promo.startDate, format: 'dd MMM yyyy')} - ${formatDate(promo.endDate, format: 'dd MMM yyyy')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const Spacer(),
                      (promo.link != null && promo.link!.isNotEmpty)
                          ? const Icon(
                              Icons.open_in_new,
                              color: Colors.grey,
                            )
                          : const SizedBox(),
                    ],
                  ),
                  const Divider(),
                  Text(
                    promo.description,
                    maxLines: 20,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          // fontWeight: FontWeight.bold,
                          // textBaseline: TextBaseline.alphabetic,
                          height: 1.0,
                        ),
                  ),
                  // const Spacer(),
                  const SizedBox(height: 20),
                  AppButton(
                    'Cek Status',
                    () => showPerformance(promo),
                    // execAction(historyAction.purchase, history),
                    size: const Size(1000, 40),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItems(BuildContext context) {
    var items = promoState.promoList;
    var isLoading = promoState.isLoading;

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
              child: Text('Tidak ada promo'),
            )
          : Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    key: const PageStorageKey<String>('listPromo'),
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return item(items[index]);
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
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
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
