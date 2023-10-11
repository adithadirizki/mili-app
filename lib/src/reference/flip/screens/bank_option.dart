import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/theme.dart';

class BankOptionFlip extends StatefulWidget {
  final List<Vendor> items;
  final Function(Vendor) onVendorSelected;

  const BankOptionFlip({
    Key? key,
    required this.items,
    required this.onVendorSelected,
  }) : super(key: key);

  @override
  _BankOptionFlipState createState() => _BankOptionFlipState();
}

class _BankOptionFlipState extends State<BankOptionFlip> {
  Vendor? vendorSelected;
  List<Vendor> vendorFiltered = [];

  @override
  void initState() {
    super.initState();
    vendorFiltered = widget.items;
  }

  void onSearchChange(String? value) {
    vendorFiltered = widget.items.where((element) {
      return element.name.toLowerCase().contains(value?.toLowerCase() ?? '');
    }).toList();

    setState(() {});
  }

  Widget itemBuilder(Vendor vendor) {
    Product? product = AppDB.productDB
        .query(Product_.code
            .equals(vendor.inquiryCode)
            .or(Product_.code.equals(vendor.paymentCode)))
        .build()
        .findFirst();

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.white24,
        onTap: () =>
            product?.status == 2 ? null : widget.onVendorSelected(vendor),
        child: ListTile(
          contentPadding:
              const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
          leading: CircleAvatar(
            radius: 18.0,
            backgroundColor: Colors.transparent,
            child: CachedNetworkImage(
              imageUrl: vendor.getImageUrl(),
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              width: 80,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          title: Text(vendor.name),
          subtitle: vendor.description.isNotEmpty || product?.status == 2
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    vendor.description.isNotEmpty
                        ? Text(vendor.description)
                        : const SizedBox(),
                    product?.status == 2
                        ? const Text(
                            'Sedang gangguan',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          )
                        : const SizedBox(),
                  ],
                )
              : null,
          enabled: !(product?.status == 2),
        ),
      ),
    );
  }

  Widget buildListVendor() {
    if (vendorFiltered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image(
              image: AppImages.flipIllustration2,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            const SizedBox(height: 20),
            const Text(
              'Kami tidak menemukan yang kamu cari. Coba tolong ketik nama, bank, atau rekening lain.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                height: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('listVendor'),
      itemCount: vendorFiltered.length,
      itemBuilder: (context, index) {
        return itemBuilder(vendorFiltered[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: const Text(
              'Pilih Bank Tujuan',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: TextField(
              cursorColor: Colors.grey,
              onChanged: onSearchChange,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                ),
                hoverColor: Colors.black,
                focusColor: Colors.grey,
                hintText: 'Cari Bank',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: Expanded(
              child: buildListVendor(),
            ),
          ),
        ],
      ),
    );
  }
}
