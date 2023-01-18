import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/screens/contacts.dart';
import 'package:miliv2/src/screens/payment.dart';
import 'package:miliv2/src/services/onesignal.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/product_topup.dart';
import 'package:miliv2/src/widgets/screen.dart';

class PurchaseTopupScreen extends StatefulWidget {
  final Vendor vendor;
  final String? destination;

  const PurchaseTopupScreen({Key? key, required this.vendor, this.destination})
      : super(key: key);

  @override
  _PurchaseTopupScreenState createState() => _PurchaseTopupScreenState();
}

class _PurchaseTopupScreenState extends State<PurchaseTopupScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();

  bool isLoading = true;
  String destinationNumber = '';
  Product? selectedProduct;

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
    selectedProduct = null;
  }

  void onProductSelected(Product? value) {
    if (isValidDestination()) {
      selectedProduct = value;
      openPayment();
    }
  }

  bool canOpenPayment() {
    return isValidDestination() && selectedProduct != null;
  }

  void openPayment() {
    if (canOpenPayment()) {
      String purchaseCode = '';
      String paymentDesc = '';
      List<SummaryItems> items = [];
      purchaseCode = selectedProduct!.code;
      items = [
        SummaryItems(
            selectedProduct!.productName,
            selectedProduct!.getUserPrice(userBalanceState.level,
                markup: userBalanceState.markup)),
      ];
      paymentDesc = 'Produk: Pembelian ${widget.vendor.name}\n'
          'No Pelanggan: $destinationNumber\n'
          'Kode Produk: ${selectedProduct!.productName}\n'
          'Nominal: ${formatNumber(selectedProduct!.nominal)}\n';
      if (selectedProduct!.description.isNotEmpty) {
        paymentDesc += '\n${selectedProduct!.description}';
      }

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

    // track trx games
    if (widget.vendor.group == menuGroupGame) {
      Map<String, dynamic> tags = await AppOnesignal.getTags();
      var _tags = {
        'last_transaction': DateTime
            .now()
            .millisecondsSinceEpoch,
        'games': parseInt(tags['games']?.toString() ?? '0') + 1,
      };
      AppOnesignal.setTags(_tags);
    }
  }

  bool isValidDestination() {
    return formKey.currentState!.validate();
  }

  void onDestinationChange(String value) {
    value = value.trim();
    if (destinationValidator(value) == null) {
      setState(() {
        destinationNumber = value;
      });
    } else if (destinationNumber.isNotEmpty) {
      setState(() {
        destinationNumber = '';
      });
    }
    // isValidDestination();
  }

  Widget buildProduct() {
    return ProductTopup(
      key: const PageStorageKey<String>('ProductTopup'),
      destination: destinationNumber,
      onProductSelected: onProductSelected,
      vendor: widget.vendor,
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
                  hint: vendorConfig?.hint ?? '08xxxxxxxx',
                  label: vendorConfig?.label ?? 'Nomor Tujuan',
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
                child: buildProduct(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
