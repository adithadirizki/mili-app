import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:objectbox/objectbox.dart';

class VendorScreen extends StatefulWidget {
  final String title;
  final String groupName;

  const VendorScreen({Key? key, required this.groupName, required this.title})
      : super(key: key);

  @override
  _VendorScreenState createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  bool isLoading = true;
  List<Vendor> vendorList = [];
  Vendor? selectedVendor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initDB();
    });
  }

  Future<void> initDB() async {
    await AppDB.syncVendor();
    QueryBuilder<Vendor> queryPulsa =
        AppDB.vendorDB.query(Vendor_.group.equals(widget.groupName));
    vendorList = queryPulsa.build().find();
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
        title: Text(vendor.name),
        subtitle:
            vendor.description.isNotEmpty ? Text(vendor.description) : null,
        // enabled: vendor.status == statusOpen,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(formatNumber(product.userPrice)),
            Radio<Vendor>(
              onChanged: onVendorSelected,
              groupValue: selectedVendor,
              value: vendor,
            ),
          ],
        ),
        onTap: () {
          onVendorSelected(vendor);
        },
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
      appBar: SimpleAppBar(title: widget.title),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: buildListVendor(context),
      ),
    );
  }
}
