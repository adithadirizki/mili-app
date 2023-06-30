import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorScreen extends StatefulWidget {
  final String title;
  final String groupName;
  final String? productCode;

  const VendorScreen({Key? key, required this.groupName, required this.title, this.productCode})
      : super(key: key);

  @override
  _VendorScreenState createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  bool isLoading = true;
  List<Vendor> vendorList = [];
  Vendor? selectedVendor;
  bool isAct = false;

  @override
  void initState() {
    super.initState();

    if (widget.groupName == menuGroupAct) {
      isAct = true;
    }

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
    // vendorList = vendorList
    //     .where((element) =>
    //         element.group.toUpperCase() == widget.groupName.toUpperCase())
    //     .toList();
    isLoading = false;
    setState(() {});
  }

  void onVendorSelected(Vendor? value) {
    selectedVendor = value;
    setState(() {});
    openPurchaseScreen(context, vendor: value);
  }

  Widget itemBuilder(Vendor vendor) {
    Product? product = AppDB.productDB.query(Product_.code.equals(vendor.inquiryCode)
        .or(Product_.code.equals(vendor.paymentCode))).build().findFirst();

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
              border: Border.all(color: Color(0xffCECECE), width: 0.5),
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
        subtitle: vendor.description.isNotEmpty || product?.status == 2 ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vendor.description.isNotEmpty ? Text(vendor.description, style: Theme.of(context).textTheme.bodySmall) : SizedBox(height: 0,),
            product?.status == 2 ? Text('Sedang gangguan', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red)) : SizedBox(height: 0,),
          ],
        ) : null,
        enabled: !(product?.status == 2),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(formatNumber(product.userPrice)),
            Radio<Vendor>(
              onChanged: (value) => product?.status == 2 ? null : onVendorSelected(value),
              groupValue: selectedVendor,
              value: vendor,
            ),
          ],
        ),
        onTap: () => product?.status == 2 ? null : onVendorSelected(vendor),
      ),
    );
  }

  Widget buildListVendor(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    if (isAct) {
      if (widget.productCode == null) {
        List<Map<String, dynamic>> providerList = [
          <String, dynamic>{'name': 'Axis', 'productCode': 'actAxis', 'image': AppImages.logoAxis},
          <String, dynamic>{'name': 'Indosat', 'productCode': 'actIndosat', 'image': AppImages.logoIndosat},
          <String, dynamic>{'name': 'Smartfren', 'productCode': 'actSmartfren', 'image': AppImages.logoSmartfren},
          <String, dynamic>{'name': 'Telkomsel', 'productCode': 'actTelkomsel', 'image': AppImages.logoTelkomsel},
          <String, dynamic>{'name': 'Three', 'productCode': 'actThree', 'image': AppImages.logoTri},
          <String, dynamic>{'name': 'XL', 'productCode': 'actXL', 'image': AppImages.logoXL},
        ];

        return Column(
          children: providerList.map((e) => Card(
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
                    border: Border.all(color: Color(0xffCECECE), width: 0.5),
                    color: const Color(0xffFBFBFB),
                    borderRadius: const BorderRadius.all(Radius.elliptical(96, 96)),
                  ),
                  padding: const EdgeInsets.all(0.5),
                  child: ClipOval(
                    child: Image(image: e['image'] as AssetImage),
                  ),
                ),
              ),
              title: Text(
                e['name'] as String,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              enabled: true,
              onTap: () {
                pushScreen(
                  context,
                      (_) => VendorScreen(
                    title: 'Aktivasi ' + (e['name'] as String),
                    groupName: menuGroupAct,
                    productCode: e['productCode'] as String,
                  ),
                );
              },
            ),
          )).toList(),
        );
      } else {
        vendorList = vendorList.where((e) => e.productCode.contains(widget.productCode!)).toList();
      }
    }

    if (vendorList.isEmpty) {
      return Center(
        child: Text(
          '-- tidak ada data --',
          style: Theme.of(context).textTheme.caption!.copyWith(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar2(title: widget.title),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            isAct ? Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 15, left: 5, right: 5),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Image(
                        image: AppImages.info,
                        color: Colors.blue,
                        width: 16,
                      ),
                      SizedBox(width: 5),
                      Text('Tutorial aktivasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  onTap: () {
                    launch('https://www.mymili.id/cara-aktivasi-voucher-paket-data-dan-perdana/');
                  },
                )
            ) : const SizedBox(),
            Expanded(child: buildListVendor(context)),
          ],
        ),
      ),
    );
  }
}
