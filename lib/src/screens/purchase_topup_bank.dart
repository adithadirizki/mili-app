import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum pages { topupList, information }

class PurchaseTopupBank extends StatefulWidget {
  final String title;
  final String groupName;

  const PurchaseTopupBank(
      {Key? key, required this.groupName, required this.title})
      : super(key: key);

  @override
  _PurchaseTopupBankState createState() => _PurchaseTopupBankState();
}

class _PurchaseTopupBankState extends State<PurchaseTopupBank> {
  final PageController pageController = PageController(initialPage: 0);
  Vendor? selectedVendor;
  pages selectedPage = pages.topupList;

  bool isLoading = true;
  List<Vendor> vendorList = [];

  String informationUrl =
      'https://www.mymili.id/informasi-layanan-transfer-bank/';

  var loadingPercentage = 0;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initDB();
    });
  }

  Future<void> initDB() async {
    await AppDB.syncVendor();
    QueryBuilder<Vendor> queryVendor =
        AppDB.vendorDB.query(Vendor_.group.equals(widget.groupName))
          ..order(Vendor_.weight, flags: 1)
          ..order(Vendor_.name);
    vendorList = queryVendor.build().find();

    vendorList = vendorList.where((vendor) {
      bool isProductBank = vendor.productType == groupVoucher;

      // Hide all product except bank
      if (!isProductBank) {
        return false;
      }

      return true;
    }).toList();

    isLoading = false;
    setState(() {});
  }

  void onPageChange(pages? mode) {
    if (mode != null) {
      setState(() {
        selectedPage = mode;
      });

      if (mode == pages.topupList) {
        pageController.jumpToPage(0);
      } else {
        pageController.jumpToPage(1);
      }
    }
  }

  void onVendorSelected(Vendor? value) {
    selectedVendor = value;
    setState(() {});
    openPurchaseScreen(context, vendor: value);
  }

  Widget itemBuilder(Vendor vendor) {
    Product? product = AppDB.productDB
        .query(Product_.code
            .equals(vendor.inquiryCode)
            .or(Product_.code.equals(vendor.paymentCode)))
        .build()
        .findFirst();

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        leading: CircleAvatar(
          radius: 18.0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffCECECE), width: 0.5),
              color: const Color(0xffFBFBFB),
              borderRadius: const BorderRadius.all(Radius.elliptical(96, 96)),
            ),
            padding: const EdgeInsets.all(0.5),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: vendor.getImageUrl(),
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                width: 100,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      // colorFilter:
                      //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          vendor.name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: vendor.description.isNotEmpty || product?.status == 2
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  vendor.description.isNotEmpty
                      ? Text(vendor.description,
                          style: Theme.of(context).textTheme.bodySmall)
                      : const SizedBox(
                          height: 0,
                        ),
                  product?.status == 2
                      ? Text('Sedang gangguan',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.red))
                      : const SizedBox(
                          height: 0,
                        ),
                ],
              )
            : null,
        enabled: !(product?.status == 2),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(formatNumber(product.userPrice)),
            Radio<Vendor>(
              onChanged: (value) =>
                  product?.status == 2 ? null : onVendorSelected(value),
              groupValue: selectedVendor,
              value: vendor,
            ),
          ],
        ),
        onTap: () => product?.status == 2 ? null : onVendorSelected(vendor),
      ),
    );
  }

  Widget buildListVendor() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    if (vendorList.isEmpty) {
      return Center(
        child: Text(
          'Layanan tidak tersedia',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('listVendor'),
      physics: const ClampingScrollPhysics(),
      itemCount: vendorList.length,
      itemBuilder: (context, index) {
        return itemBuilder(vendorList[index]);
      },
    );
  }

  Widget buildInformation() {
    return Stack(
      children: [
        WebView(
          initialUrl: informationUrl,
          zoomEnabled: true,
          javascriptMode: JavascriptMode.unrestricted,
          onWebResourceError: (error) {
            debugPrint('PrivacyScreen error $error');
          },
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer()),
          },
          onWebViewCreated: (webViewController) {
            _controller.complete(webViewController);
          },
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
        ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar2(title: widget.title),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        onPageChange(pages.topupList);
                      },
                      child: Text(
                        'Topup',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedPage == pages.topupList
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        onPageChange(pages.information);
                      },
                      child: Text(
                        'Informasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedPage == pages.information
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (value) {
                  if (value == 0) {
                    onPageChange(pages.topupList);
                  } else if (value == 1) {
                    onPageChange(pages.information);
                  }
                },
                children: [
                  buildListVendor(),
                  buildInformation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
