import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/button.dart';

class ProductPayment extends StatefulWidget {
  final String destination;
  final String inquiryCode;
  final double? amount;
  final String? productCode;
  final Function(InquiryResponse) onInquiryCompleted;
  final Vendor? vendor;

  const ProductPayment({
    Key? key,
    required this.destination,
    required this.inquiryCode,
    required this.onInquiryCompleted,
    this.amount,
    this.productCode,
    this.vendor,
  }) : super(key: key);

  @override
  ProductPaymentState createState() => ProductPaymentState();
}

class ProductPaymentState extends State<ProductPayment> {
  InquiryResponse? inquiryResult;
  bool isLoading = false;
  String trxId = '';

  Cutoff? cutoff;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initDB();
    });
  }

  void initDB() async {
    // inquiry code or group from voucher config
    final cutoffDB = AppDB.cutoffDB;
    cutoff = cutoffDB
        .query(Cutoff_.productCode
            .equals(widget.inquiryCode, caseSensitive: false)
            .or(Cutoff_.productCode
                .equals(widget.vendor?.group ?? '', caseSensitive: false)))
        .build()
        .findFirst();
    setState(() {});
  }

  void reset() {
    trxId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      inquiryResult = null;
    });
  }

  Widget info() {
    if (cutoff == null || cutoff?.notes == null || !isClosed(cutoff)) {
      return Container();
    }

    return Container(
      color: AppColors.blue4.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Text(cutoff?.notes ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, height: 1.5))
              ],
            ),
          )
        ],
      ),
    );
  }

  bool isValidDestination() {
    return widget.destination.isNotEmpty &&
        widget.inquiryCode.isNotEmpty &&
        (widget.amount == null || widget.amount! > 0) &&
        (widget.productCode == null || widget.productCode!.isNotEmpty);
  }

  bool canOpenPayment() {
    return isValidDestination() && inquiryResult != null;
  }

  Future<void> inquiryPayment() async {
    // popScreen(context);
    setState(() {
      isLoading = true;
    });
    await Api.inquiryPayment(
      trxId: trxId,
      inquiryCode: widget.inquiryCode,
      destination: widget.destination,
      amount: widget.amount,
      productCode: widget.productCode,
    ).then(handleInquiryResponse).catchError(handleError);
  }

  void handleInquiryResponse(Response response) {
    setState(() {
      isLoading = false;
      inquiryResult = InquiryResponse.fromString(response.body);
    });
  }

  FutureOr<void> handleError(Object e) {
    snackBarDialog(context, e.toString());
    setState(() {
      isLoading = false;
    });
  }

  void onContinuePayment() {
    widget.onInquiryCompleted(
      inquiryResult!,
    );
  }

  Widget buildInquiryResult() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    if (inquiryResult != null) {
      return Container(
        alignment: Alignment.topLeft,
        child: Text(
          inquiryResult!.inquiryDetail,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Container(
      alignment: Alignment.topCenter,
      child: Text(
        'Masukkan nomor pelanggan dan cek tagihan',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        info(),
        const SizedBox(height: 5),
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: Container(
            // color: Colors.lightBlueAccent,
            width: double.infinity,
            alignment: Alignment.topLeft,
            child: buildInquiryResult(),
          ),
        ),
        const SizedBox(height: 5),
        AppButton(
            inquiryResult == null ? 'Cek Tagihan' : 'Lanjutkan',
            isLoading
                ? null
                : isClosed(cutoff) == false
                    ? (isValidDestination()
                        ? (inquiryResult == null
                            ? inquiryPayment
                            : onContinuePayment)
                        : null)
                    : null),
        const SizedBox(height: 5),
      ],
    );
  }
}
