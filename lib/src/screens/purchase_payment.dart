import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final postpaidKey = GlobalKey<ProductPaymentState>();

  bool isLoading = true;
  String destinationNumber = '';
  InquiryResponse? inquiryResponse;

  @override
  void initState() {
    super.initState();
    destinationNumber = widget.destination ?? '';
    textController.text = widget.destination ?? '';
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
    return destinationNumber.isNotEmpty;
  }

  void onDestinationChange(String value) {
    value = value.trim();
    if (postpaidKey.currentState != null) {
      postpaidKey.currentState!.reset();
    }
    if (destinationNumber != value && value.length > 3) {
      setState(() {
        destinationNumber = value;
      });
    } else if (destinationNumber.isNotEmpty) {
      setState(() {
        destinationNumber = '';
      });
    }
  }

  Widget buildProduct(BuildContext context) {
    return ProductPayment(
      key: postpaidKey,
      destination: destinationNumber,
      inquiryCode: widget.vendor.inquiryCode,
      onInquiryCompleted: onInquiryCompleted,
    );
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
                  hint: '0123456789',
                  label: 'Nomor Pelanggan',
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor tidak sesuai ';
                  }
                  return null;
                },
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
