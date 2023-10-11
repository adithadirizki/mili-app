import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/reference/flip/widgets/button.dart';
import 'package:miliv2/src/reference/flip/widgets/dialog.dart';
import 'package:miliv2/src/theme.dart';

class ProductBankFlipScreen extends StatefulWidget {
  final Vendor? selectedVendor;
  final String? destination;

  const ProductBankFlipScreen({
    Key? key,
    this.selectedVendor,
    this.destination,
  }) : super(key: key);

  @override
  _ProductBankFlipScreenState createState() => _ProductBankFlipScreenState();
}

class _ProductBankFlipScreenState extends State<ProductBankFlipScreen> {
  bool isLoading = true;
  List<Vendor> vendorList = [];
  List<Vendor> vendorFiltered = [];
  Vendor? _selectedVendor;
  String? _destination;

  String searchValue = '';

  @override
  void initState() {
    super.initState();

    _selectedVendor = widget.selectedVendor;
    _destination = widget.destination;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initDB();
    });
  }

  Future<void> initDB() async {
    await AppDB.syncVendor();
    QueryBuilder<Vendor> queryVendor =
        AppDB.vendorDB.query(Vendor_.group.equals(menuGroupEmoney))
          ..order(Vendor_.weight, flags: 1)
          ..order(Vendor_.name);
    vendorList = queryVendor.build().find();

    vendorList = vendorList.where((vendor) {
      bool isProductBank = vendor.productType == vendorTypeTransferBank;

      // Hide all product except bank
      if (!isProductBank) {
        return false;
      }

      return true;
    }).toList();

    vendorFiltered = vendorList;

    isLoading = false;
    setState(() {});

    if (_selectedVendor != null) {
      showPageBankInquiry();
    }
  }

  void showPageBankInquiry() {
    showDestinationBankFlip(
      context: context,
      items: vendorList,
      selectedVendor: _selectedVendor,
      destination: _destination,
    );

    // reset
    _selectedVendor = null;
    _destination = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              child: const Icon(
                Icons.chevron_left,
                color: Colors.black,
                size: 30,
              ),
              onTap: () {
                Navigator.maybePop(context);
              },
            ),
            const Text(
              'Transfer ke Rekening Bank',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF5731),
                  strokeWidth: 5,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image(
                      image: AppImages.flipIllustration1,
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: Text(
                      'Hai ${userBalanceState.name}, Mau transfer uang ke bank apa nih?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ButtonFlip(
                    child: const Text('Pilih Bank Tujuan'),
                    onPressed: showPageBankInquiry,
                  ),
                ],
              ),
      ),
    );
  }
}
