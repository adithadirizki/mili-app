import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/screens/contacts.dart';
import 'package:miliv2/src/screens/payment.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/product_paket_data.dart';
import 'package:miliv2/src/widgets/product_payment.dart';
import 'package:miliv2/src/widgets/screen.dart';

enum productMode { prepaid, postpaid }

class PurchasePaketDataScreen extends StatefulWidget {
  final String? productCode;
  final String? destination;

  const PurchasePaketDataScreen({Key? key, this.productCode, this.destination})
      : super(key: key);

  @override
  _PurchasePaketDataScreenState createState() =>
      _PurchasePaketDataScreenState();
}

class _PurchasePaketDataScreenState extends State<PurchasePaketDataScreen> {
  final PageController pageController = PageController(initialPage: 0);
  final formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();

  final postpaidKey = GlobalKey<ProductPaymentState>();

  productMode selectedMode = productMode.prepaid;

  String destinationNumber = '';
  Product? selectedProduct;

  // Postpaid product
  String postpaidInquiryCode = '';
  String postpaidPaymentCode = '';
  InquiryResponse? inquiryResponse;
  final Map<String, Set<String>> postpaidPrefix = {
    '+62811,+62812,+62813,+62851,+62852,+62853,+62821,+62822,+62823': {
      'CEKHALO',
      'PAYHALO'
    },
    '+62814,+62815,+62816,+62816,+62855,+62815,+62858,+62856,+62857	': {
      'CEKMATRIX',
      'PAYMATRIX'
    },
    '+62888,+62881,+62882,+62889,+62887,+62222,+628831': {
      'CEKSMART',
      'PAYSMART'
    },
    '+62899,+62898,+62897,+62896,+62895,+62892,+62891,+62893': {
      'CEKTHREE',
      'PAYTHREE'
    },
    '+62817,+62818,+62819,+62878,+62879,+62877,+62875,+62859': {
      'CEKXPLOR',
      'PAYXPLOR'
    },
  };

  @override
  void initState() {
    super.initState();
    destinationNumber = widget.destination ?? '';
    textController.text = widget.destination ?? '';
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() {
    if (widget.productCode != null) {
      if (widget.productCode!.startsWith('PAY')) {
        onModeChange(productMode.postpaid);

        var prefix = getDestinationPrefix(destinationNumber);
        for (var key in postpaidPrefix.keys) {
          if (key.contains(prefix)) {
            postpaidInquiryCode = postpaidPrefix[key]!.elementAt(0);
            postpaidPaymentCode = postpaidPrefix[key]!.elementAt(1);
            break;
          }
        }
      }
    }
  }

  // FutureOr<Null> _handleError(Object e) {
  //   snackBarDialog(context, e.toString());
  // }

  void reset() {
    textController.clear();
    destinationNumber = '';
    selectedProduct = null;
    onModeChange(productMode.prepaid);
    if (postpaidKey.currentState != null) {
      postpaidKey.currentState!.reset();
    }
  }

  void onModeChange(productMode? mode) {
    if (mode != null) {
      // textController.clear();
      setState(() {
        // postpaidInquiryResult = '';
        // destinationNumber = '';
        selectedMode = mode;
      });

      if (mode == productMode.prepaid) {
        pageController.jumpToPage(0);
      } else {
        pageController.jumpToPage(1);
      }
    }
  }

  void onProductSelected(Product? value) {
    selectedProduct = value;
    if (selectedProduct != null) {
      openPayment();
    }
  }

  void onInquiryCompleted(InquiryResponse response) {
    inquiryResponse = response;
    openPayment();
  }

  void onDestinationChange(String value) {
    value = value.trim();
    if (postpaidKey.currentState != null) {
      postpaidKey.currentState!.reset();
    }
    if (destinationValidator(value) == null) {
      // Filter postpaid
      var prefix = getDestinationPrefix(destinationNumber);
      for (var key in postpaidPrefix.keys) {
        if (key.contains(prefix)) {
          postpaidInquiryCode = postpaidPrefix[key]!.elementAt(0);
          postpaidPaymentCode = postpaidPrefix[key]!.elementAt(1);
          break;
        }
      }

      debugPrint('Inquiry code $postpaidInquiryCode - $postpaidPaymentCode');

      setState(() {
        destinationNumber = value;
        inquiryResponse = null;
      });
    } else if (destinationNumber.isNotEmpty) {
      setState(() {
        destinationNumber = '';
        inquiryResponse = null;
        postpaidInquiryCode = '';
      });
    }
  }

  void _onPaymentConfirmed() {
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

  void openPayment() {
    debugPrint('Open Payment $selectedProduct');
    if (canOpenPayment()) {
      String purchaseCode = '';
      String paymentDesc = '';
      List<SummaryItems> items = [];
      if (selectedMode == productMode.prepaid) {
        purchaseCode = selectedProduct!.code;
        items = [
          SummaryItems(
              selectedProduct!.productName,
              selectedProduct!.getUserPrice(userBalanceState.level,
                  markup: userBalanceState.markup)),
        ];
        if (selectedProduct!.productGroup == groupData) {
          paymentDesc = 'Produk: Paket Data\n'
              'No Pelanggan: $destinationNumber\n'
              'Paket: ${selectedProduct!.productName}\n';
          if (selectedProduct!.description.isNotEmpty) {
            paymentDesc += '\n${selectedProduct!.description}';
          }
        } else if (selectedMode == productMode.prepaid) {
          paymentDesc = 'Produk: Pulsa Prabayar\n'
              'No Pelanggan: $destinationNumber\n'
              'Kode Produk: ${selectedProduct!.productName}\n'
              'Nominal: ${formatNumber(selectedProduct!.nominal)}\n';
          if (selectedProduct!.description.isNotEmpty) {
            paymentDesc += '\n${selectedProduct!.description}';
          }
        }
      } else if (selectedMode == productMode.postpaid &&
          inquiryResponse != null) {
        purchaseCode = postpaidPaymentCode;
        items = [
          SummaryItems('Pembayaran paket data postpaid', inquiryResponse!.amount),
        ];
        paymentDesc = inquiryResponse!.inquiryDetail;
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
          onPaymentConfirmed: _onPaymentConfirmed,
        );
      });
    } else {
      snackBarDialog(context, 'Masukkan nomor tujuan');
    }
  }

  bool isValidDestination() {
    return formKey.currentState!.validate();
  }

  bool canOpenPayment() {
    return isValidDestination() &&
        (selectedProduct != null || inquiryResponse != null);
  }

  Widget buildPrepaidScreen() {
    return ProductPaketData(
      key: const PageStorageKey<String>('ProductPaketData'),
      level: userBalanceState.level,
      destination: destinationNumber,
      onProductSelected: onProductSelected,
    );
  }

  Widget buildPostpaidScreen() {
    return ProductPayment(
      key: postpaidKey,
      destination: destinationNumber,
      inquiryCode: postpaidInquiryCode,
      onInquiryCompleted: onInquiryCompleted,
    );
  }

  String? destinationValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Isi nomor tujuan ';
    } else if ((value.length < 5) || (value.length > 15)) {
      return 'Nomor tidak sesuai ';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: 'Paket Data'),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Radio<productMode>(
                        onChanged: onModeChange,
                        groupValue: selectedMode,
                        value: productMode.prepaid,
                      ),
                      GestureDetector(
                        onTap: () {
                          onModeChange(productMode.prepaid);
                        },
                        child: const Text("Prabayar"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<productMode>(
                        onChanged: onModeChange,
                        groupValue: selectedMode,
                        value: productMode.postpaid,
                      ),
                      GestureDetector(
                        onTap: () {
                          onModeChange(productMode.postpaid);
                        },
                        child: const Text('Pascabayar'),
                      ),
                    ],
                  ),
                ],
              ),
              TextFormField(
                controller: textController,
                decoration: generateInputDecoration(
                  hint: '08xxxxxxxx',
                  label: 'Nomor Ponsel',
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
                child: PageView(
                  controller: pageController,
                  key: const ValueKey('pagemode'),
                  onPageChanged: (value) {
                    if (value == 0) {
                      onModeChange(productMode.prepaid);
                    } else if (value == 1) {
                      onModeChange(productMode.postpaid);
                    }
                  },
                  children: [
                    buildPrepaidScreen(),
                    buildPostpaidScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
