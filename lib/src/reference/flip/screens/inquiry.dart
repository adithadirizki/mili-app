import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/reference/flip/screens/payment.dart';
import 'package:miliv2/src/reference/flip/widgets/button.dart';
import 'package:miliv2/src/reference/flip/widgets/dialog.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';

class InquiryScreenFlip extends StatefulWidget {
  final Vendor vendor;
  final String? destination;

  const InquiryScreenFlip({
    Key? key,
    required this.vendor,
    this.destination,
  }) : super(key: key);

  @override
  _InquiryScreenFlipState createState() => _InquiryScreenFlipState();
}

class _InquiryScreenFlipState extends State<InquiryScreenFlip> {
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();

  bool isLoading = false;
  bool isValid = false;
  String destination = '';
  String nominal = '';
  String trxId = DateTime.now().millisecondsSinceEpoch.toString();

  VendorConfigResponse? vendorConfig;

  @override
  void initState() {
    super.initState();
    destinationController.text = widget.destination ?? '';
    vendorConfig = widget.vendor.configMap;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? validateInput() {
    String destination = destinationController.value.text;
    double nominal = parseDouble(nominalController.value.text);
    int minLengthDestination = vendorConfig!.minLength ?? 0;
    double minNominal = vendorConfig!.minDemon ?? 0;

    if (destination.length < minLengthDestination) {
      return 'Nomor rekening tidak valid';
    } else if (nominal < minNominal) {
      return 'Minimal jumlah transfer ${formatNumber(minNominal)}';
    }

    return null;
  }

  void onConfirmInquiry() {
    if (isLoading) return;

    String? inputError = validateInput();

    if (inputError != null) {
      alertDialogFlip(context, inputError);
      return;
    }

    inquiryPayment();
  }

  void onDestinationChange(String value) {
    setState(() {
      isValid = destinationController.text.isNotEmpty &&
          nominalController.text.isNotEmpty;
    });
  }

  void onAmountChange(String value) {
    setState(() {
      isValid = destinationController.text.isNotEmpty &&
          nominalController.text.isNotEmpty;
    });

    double nominal = parseDouble(value);

    // max input jumlah transfer
    if (nominal > (vendorConfig!.maxDemon ?? 0)) {
      nominal = vendorConfig!.maxDemon ?? 0;
    }

    String currency = formatNumber(nominal);

    nominalController.value = TextEditingValue(
      text: currency,
      selection: TextSelection.collapsed(
        offset: currency.length,
      ),
    );
  }

  Future<void> inquiryPayment() async {
    setState(() {
      isLoading = true;
    });

    await Api.inquiryPayment(
      trxId: trxId,
      inquiryCode: widget.vendor.inquiryCode,
      destination: destinationController.text,
      amount: parseDouble(nominalController.text),
    ).then((response) {
      setState(() {
        isLoading = false;
      });

      Map<String, dynamic>? body =
          jsonDecode(response.body) as Map<String, dynamic>;

      String accountName = body['name'].toString();
      double amount = parseDouble(body['amount'].toString());
      double adminFee = parseDouble(body['admin_fee'].toString());
      double nominal = parseDouble(body['nominal'].toString());

      pushScreen(
        context,
        (_) {
          return PaymentScreenFlip(
            destination: destinationController.text,
            vendor: widget.vendor,
            accountName: accountName,
            amount: amount,
            adminFee: adminFee,
            nominal: nominal,
          );
        },
      );
    }).catchError(handleOnError);
  }

  FutureOr<void> handleOnError(Object e) {
    alertDialogFlip(context, e.toString());
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(90),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.black45,
                      size: 30,
                    ),
                  ),
                  onTap: () {
                    Navigator.maybePop(context);
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  'Masukkan Rekening Tujuan',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: Colors.black12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CachedNetworkImage(
                            width: 70,
                            height: 50,
                            imageUrl: widget.vendor.getImageUrl(),
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            widget.vendor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, color: Colors.black12),
                      TextFormField(
                        maxLength: vendorConfig!.maxLength,
                        controller: destinationController,
                        decoration: const InputDecoration(
                          counterStyle: TextStyle(
                            height: double.minPositive,
                          ),
                          counterText: "",
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          labelText: 'Nomor Rekening',
                          hintText: '012345678',
                          labelStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: onDestinationChange,
                      ),
                      const Divider(thickness: 1, color: Colors.black12),
                      TextFormField(
                        controller: nominalController,
                        decoration: const InputDecoration(
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          labelText: 'Jumlah Transfer',
                          hintText: '100.000',
                          labelStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w900,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: onAmountChange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ButtonFlip(
                  child: isLoading
                      ? Transform.scale(
                          scale: 0.5,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 5,
                          ),
                        )
                      : const Text('Cek Rekening'),
                  onPressed: isValid ? onConfirmInquiry : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
