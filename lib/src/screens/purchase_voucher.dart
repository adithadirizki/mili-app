import 'package:flutter/material.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/screens/payment.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/product_topup.dart';
import 'package:miliv2/src/widgets/screen.dart';

class PurchaseVoucherScreen extends StatefulWidget {
  final Vendor vendor;
  final String? destination;

  const PurchaseVoucherScreen(
      {Key? key, required this.vendor, this.destination})
      : super(key: key);

  @override
  _PurchaseVoucherScreenState createState() => _PurchaseVoucherScreenState();
}

class _PurchaseVoucherScreenState extends State<PurchaseVoucherScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();

  bool isLoading = true;
  // String destinationNumber = '';
  Product? selectedProduct;

  @override
  void initState() {
    super.initState();
    // destinationNumber = widget.destination ?? '';
    // textController.text = widget.destination ?? '';
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reset() {
    textController.clear();
    // destinationNumber = '';
    selectedProduct = null;
  }

  void onProductSelected(Product? value) {
    // if (isValidDestination()) {
    selectedProduct = value;
    openPayment();
    // } else {
    //   showSnackBar(context, 'Masukkan nomor tujuan');
    // }
  }

  bool canOpenPayment() {
    return selectedProduct != null;
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
      paymentDesc = 'Produk: Pembelian Voucher ${widget.vendor.name}\n'
          // 'No Pelanggan: $destinationNumber\n'
          'Produk: ${selectedProduct!.productName}\n';
      if (selectedProduct!.description.isNotEmpty) {
        paymentDesc += '\n${selectedProduct!.description}';
      }

      double total = items.fold(
          0, (previousValue, element) => previousValue + element.price);

      pushScreen(context, (ctx) {
        return PaymentScreen(
          purchaseCode: purchaseCode,
          destination: userBalanceState.userId,
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

  // bool isValidDestination() {
  //   return destinationNumber.isNotEmpty;
  // }

  // void onDestinationChange(String value) {
  //   value = value.trim();
  //   if (destinationNumber != value && value.length > 3) {
  //     setState(() {
  //       destinationNumber = value;
  //     });
  //   } else if (destinationNumber.isNotEmpty) {
  //     setState(() {
  //       destinationNumber = '';
  //     });
  //   }
  // }

  Widget buildProduct() {
    return ProductTopup(
      key: const PageStorageKey<String>('ProductTopup'),
      destination: userBalanceState.userId,
      onProductSelected: onProductSelected,
      vendor: widget.vendor,
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
              // TextFormField(
              //   controller: textController,
              //   decoration: generateInputDecoration(
              //     hint: '08xxxxxxxx',
              //     label: 'Nomor Tujuan',
              //     onClear: destinationNumber.isNotEmpty
              //         ? () {
              //             textController.clear();
              //             onDestinationChange('');
              //           }
              //         : null,
              //   ),
              //   keyboardType: TextInputType.number,
              //   textInputAction: TextInputAction.done,
              //   inputFormatters: [
              //     FilteringTextInputFormatter.digitsOnly,
              //   ],
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Nomor tidak sesuai ';
              //     }
              //     return null;
              //   },
              //   onChanged: onDestinationChange,
              // ),
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
