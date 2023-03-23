import 'package:flutter/material.dart';
import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/screens/purchase_payment_aktivasi.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/product_topup.dart';

class PurchaseAktivasiScreen extends StatefulWidget {
  final Vendor vendor;
  final String? destination;

  const PurchaseAktivasiScreen({Key? key, required this.vendor, this.destination})
      : super(key: key);

  @override
  _PurchaseAktivasiScreenState createState() => _PurchaseAktivasiScreenState();
}

class _PurchaseAktivasiScreenState extends State<PurchaseAktivasiScreen> {
  Product? selectedProduct;

  VendorConfigResponse? vendorConfig;

  @override
  void initState() {
    super.initState();
    vendorConfig = widget.vendor.configMap;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onProductSelected(Product? value) {
    selectedProduct = value;
    pushScreen(context, (ctx) {
      return PurchasePaymentAktivasiScreen(vendor: widget.vendor, product: selectedProduct!, destination: widget.destination);
    });
  }

  Widget buildProduct() {
    return ProductTopup(
      key: const PageStorageKey<String>('ProductTopup'),
      destination: widget.destination ?? '',
      onProductSelected: onProductSelected,
      vendor: widget.vendor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: widget.vendor.name),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: buildProduct(),
      ),
    );
  }
}
