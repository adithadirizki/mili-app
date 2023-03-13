import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/api/profile.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/screens/payment.dart';
import 'package:miliv2/src/screens/scanner.dart';
import 'package:miliv2/src/services/storage.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';

class PurchasePaymentAktivasiScreen extends StatefulWidget {
  final Vendor vendor;
  final Product product;
  final String? destination;

  const PurchasePaymentAktivasiScreen({Key? key, required this.vendor, required this.product, this.destination})
      : super(key: key);

  @override
  _PurchasePaymentAktivasiScreenState createState() => _PurchasePaymentAktivasiScreenState();
}

class _PurchasePaymentAktivasiScreenState extends State<PurchasePaymentAktivasiScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textController1 = TextEditingController();
  final TextEditingController textController2 = TextEditingController();
  final TextEditingController textController3 = TextEditingController();

  bool isLoading = true;
  String destinationStart = '';
  String destinationEnd = '';
  int? totalVcr;
  double harga = 0;
  double totalHarga = 0;
  ProfileConfig profileConfig = ProfileConfig();

  VendorConfigResponse? vendorConfig;

  @override
  void initState() {
    super.initState();

    var userProfile = AppStorage.getUserProfile(); // Cache
    Map<String, dynamic> bodyMap =
    json.decode(userProfile) as Map<String, dynamic>;
    profileConfig =
    ProfileConfig.fromJson(bodyMap['config'] as Map<String, dynamic>);

    textController2.text = textController1.text = widget.destination ?? '';
    textController3.text = widget.destination != null ? '1' : '';

    destinationEnd = destinationStart = widget.destination ?? '';
    harga = widget.product.getUserPrice(userBalanceState.level,
        markup: userBalanceState.markup);
    totalHarga = harga;
    vendorConfig = widget.vendor.configMap;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reset() {
    textController1.clear();
    textController2.clear();
    textController3.clear();
  }

  bool canOpenPayment() {
    return isValidForm();
  }

  void openPayment() {
    if (canOpenPayment()) {
      String purchaseCode = '';
      String paymentDesc = '';
      List<SummaryItems> items = [];
      purchaseCode = widget.product.code;
      double harga = widget.product.getUserPrice(userBalanceState.level,
          markup: userBalanceState.markup);
      double totalHrg = harga * parseInt(textController3.text);
      items = [SummaryItems(
          widget.product.productName,
          totalHrg)];
      // items.add(item);
      paymentDesc = 'Produk: Pembelian ${widget.vendor.name}\n'
          'Kode Voucher Awal: $destinationStart\n'
          'Kode Voucher Akhir: $destinationEnd\n'
          'Kode Produk: ${widget.product.productName}\n'
          'Nominal: ${formatNumber(widget.product.nominal)}\n'
          'Harga: ${formatNumber(harga)}\n'
          'Jumlah Voucher: $totalVcr\n'
          'Total Harga: ${formatNumber(totalHrg)}\n';
      if (widget.product.description.isNotEmpty) {
        paymentDesc += '\n${widget.product.description}';
      }

      double total = items.fold(
          0, (previousValue, element) => previousValue + element.price);

      pushScreen(context, (ctx) {
        return PaymentScreen(
          purchaseCode: purchaseCode,
          destination: destinationStart,
          totalVcr: totalVcr,
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

  void onPaymentConfirmed() async {
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

  bool isValidForm() {
    return formKey.currentState!.validate();
  }

  void onDestinationChange(String value) {
    value = value.trim();
    textController1.text = parseInt(value).toString();

    if (formKey.currentState == null) {
      formKey.currentState!.reset();
    }
    setState(() {
      destinationStart = value;
      textController1.selection = TextSelection.fromPosition(TextPosition(offset: textController1.text.length));
      textController2.text = destinationEnd = (parseInt(value) + parseInt(textController3.text) - 1).toString();
    });
    isValidForm();
  }

  void onTotalVcrChange(String value) {
    textController3.text = parseInt(value).toString();
    totalVcr = profileConfig.maxVoucher;

    if (formKey.currentState == null) {
      formKey.currentState!.reset();
    }
    setState(() {
      totalVcr = parseInt(value);
      totalHarga = parseInt(value) * harga;
      textController3.selection = TextSelection.fromPosition(TextPosition(offset: textController3.text.length));
      textController2.text = destinationEnd = (parseInt(destinationStart) + parseInt(value) - 1).toString();
    });
    isValidForm();
  }

  String? totalVcrValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan jumlah voucher';
    } else if (parseInt(value) < profileConfig.minVoucher) {
      return 'Minimal jumlah voucher ' + profileConfig.minVoucher.toString();
    } else if (parseInt(value) > profileConfig.maxVoucher) {
      return 'Maksimal jumlah voucher ' + profileConfig.maxVoucher.toString();
    }
    return null;
  }

  String? destinationValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Isi kode voucher ';
    } else if (vendorConfig != null) {
      var config = vendorConfig!;
      if ((config.minLength != null &&
              config.minLength! > 0 &&
              value.length < config.minLength!) ||
          (config.maxLength != null &&
              config.maxLength! > 0 &&
              value.length > config.maxLength!)) {
        return 'Kode voucher tidak sesuai ';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: widget.vendor.name),
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Form(
          key: formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18.0,
                    // backgroundImage: getProductLogo(product),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffCECECE), width: 0.5),
                        color: const Color(0xffFBFBFB),
                        borderRadius:
                        const BorderRadius.all(Radius.elliptical(96, 96)),
                      ),
                      padding: const EdgeInsets.all(0.5),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.vendor.getImageUrl(),
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
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Rp' + formatNumber(harga) + ' / Transaksi',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    heightFactor: 2,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      vendorConfig?.label != null ? '${vendorConfig?.label} Awal' : 'Kode Voucher Awal',
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                  ),
                  TextFormField(
                    controller: textController1,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      hintText: '23768888121200',
                      hintStyle: const TextStyle(color: Color(0xC5C5C5C5)),
                      border: InputBorder.none,
                      suffixIcon: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: AppColors.gradientBlue1
                            ),
                            onPressed: () async {
                              var code = await pushScreenWithCallback<String>(
                                context,
                                    (_) => const ScannerScreen(),
                              );
                              if (code != null) {
                                textController1.text = code;
                                textController3.text = '1';
                                totalHarga = harga;
                                setState(() {});
                                onDestinationChange(code);
                              }
                            },
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: destinationValidator,
                    onChanged: onDestinationChange,
                  ),
                  Align(
                    heightFactor: 2,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      vendorConfig?.label != null ? '${vendorConfig?.label} Akhir' : 'Kode Voucher Akhir',
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                  ),
                  TextFormField(
                    controller: textController2,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      hintText: '23768888121200',
                      hintStyle: TextStyle(color: Color(0xC5C5C5C5)),
                      border: InputBorder.none,
                    ),
                    enabled: false,
                  ),
                  const Align(
                    heightFactor: 2,
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'Jumlah Voucher',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                  ),
                  TextFormField(
                    controller: textController3,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      hintText: '1',
                      hintStyle: TextStyle(color: Color(0xC5C5C5C5)),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: totalVcrValidator,
                    onChanged: onTotalVcrChange,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    heightFactor: 2,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rp' + formatNumber(totalHarga),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // minimumSize: Size.zero,
                        primary: AppColors.gradientBlue1
                      ),
                      onPressed: () {
                        if (isValidForm()) openPayment();
                      },
                      child: const Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.bold))
                    )
                  )
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
          )
        ),
      ),
    );
  }
}
