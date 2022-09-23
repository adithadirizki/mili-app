import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/screens/contacts.dart';
import 'package:miliv2/src/screens/payment.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/product_payment.dart';
import 'package:miliv2/src/widgets/screen.dart';

class PurchasePaymentScreen extends StatefulWidget {
  final Vendor vendor;
  final String? destination;

  const PurchasePaymentScreen(
      {Key? key, required this.vendor, this.destination})
      : super(key: key);

  @override
  _PurchasePaymentScreenState createState() => _PurchasePaymentScreenState();
}

class _PurchasePaymentScreenState extends State<PurchasePaymentScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();
  final paymentKey = GlobalKey<ProductPaymentState>();

  bool isLoading = true;
  String destinationNumber = '';
  InquiryResponse? inquiryResponse;

  VendorConfigResponse? vendorConfig;

  @override
  void initState() {
    super.initState();
    destinationNumber = widget.destination ?? '';
    textController.text = widget.destination ?? '';
    vendorConfig = widget.vendor.configMap;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reset() {
    textController.clear();
    destinationNumber = '';
  }

  void onInquiryCompleted(InquiryResponse response) {
    inquiryResponse = response;
    openPayment();
  }

  bool canOpenPayment() {
    return isValidDestination() && inquiryResponse != null;
  }

  void openPayment() {
    if (canOpenPayment()) {
      String purchaseCode = '';
      String paymentDesc = '';
      List<SummaryItems> items = [];
      //
      purchaseCode = widget.vendor.paymentCode;
      items = [
        SummaryItems(
            'Pembayaran ${widget.vendor.name}', inquiryResponse!.amount),
      ];
      paymentDesc = inquiryResponse!.inquiryDetail;
      double total = items.fold(
          0, (previousValue, element) => previousValue + element.price);

      pushScreen(context, (ctx) {
        return PaymentScreen(
          purchaseCode: purchaseCode,
          destination: destinationNumber,
          description: paymentDesc,
          items: items,
          total: total,
          onPaymentConfirmed: onPaymentConfirmed,
        );
      });
    } else {
      snackBarDialog(context, 'Masukkan nomor tujuan');
    }
  }

  void onPaymentConfirmed() {
    confirmDialog(
      context,
      title: 'Konfirmasi',
      msg: 'Pembelian sedang diproses, lanjutkan transaksi ?',
      confirmAction: () {
        reset();
      },
      cancelAction: () {
        popScreen(context);
      },
      confirmText: 'Ya',
      cancelText: 'Tidak',
    );
  }

  bool isValidDestination() {
    return formKey.currentState!.validate();
  }

  void onDestinationChange(String value) {
    value = value.trim();
    if (paymentKey.currentState != null) {
      paymentKey.currentState!.reset();
    }
    if (destinationValidator(value) == null) {
      setState(() {
        destinationNumber = value;
      });
    } else if (destinationNumber.isNotEmpty) {
      setState(() {
        destinationNumber = '';
      });
    }
    isValidDestination();
  }

  Widget buildProduct(BuildContext context) {
    return ProductPayment(
      key: paymentKey,
      destination: destinationNumber,
      inquiryCode: widget.vendor.inquiryCode,
      onInquiryCompleted: onInquiryCompleted,
    );
  }

  String? destinationValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Isi nomor tujuan ';
    } else if (vendorConfig != null) {
      var config = vendorConfig!;
      if ((config.minLength != null &&
              config.minLength! > 0 &&
              value.length < config.minLength!) ||
          (config.maxLength != null &&
              config.maxLength! > 0 &&
              value.length > config.maxLength!)) {
        return 'Nomor tidak sesuai ';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: widget.vendor.name),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: textController,
                decoration: generateInputDecoration(
                  hint: vendorConfig?.hint ?? '0123456789',
                  label: vendorConfig?.label ?? 'Nomor Pelanggan',
                  onClear: destinationNumber.isNotEmpty
                      ? () {
                          textController.clear();
                          onDestinationChange('');
                        }
                      : null,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.contact_phone,
                      color: AppColors.black1,
                    ),
                    onPressed: () async {
                      final String? contactNumber =
                          await pushScreenWithCallback<String>(
                        context,
                        (_) => ContactScreen(),
                      );
                      if (contactNumber != null) {
                        textController.text = contactNumber;
                        onDestinationChange(contactNumber);
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: destinationValidator,
                onChanged: onDestinationChange,
              ),
              FlexBoxGray(
                margin: const EdgeInsets.only(top: 10),
                child: buildProduct(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
