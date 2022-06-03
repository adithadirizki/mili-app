import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/screens/payment.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/product_payment.dart';
import 'package:miliv2/src/widgets/screen.dart';
import 'package:objectbox/internal.dart';

enum productMode { prepaid, postpaid }

class PurchasePLNScreen extends StatefulWidget {
  final String? productCode;
  final String? destination;

  const PurchasePLNScreen({Key? key, this.productCode, this.destination})
      : super(key: key);

  @override
  _PurchasePLNScreenState createState() => _PurchasePLNScreenState();
}

class _PurchasePLNScreenState extends State<PurchasePLNScreen> {
  final PageController pageController = PageController(initialPage: 0);
  final formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();

  final prepaidKey = GlobalKey<ProductPaymentState>();
  final postpaidKey = GlobalKey<ProductPaymentState>();

  productMode selectedMode = productMode.prepaid;

  String destinationNumber = '';

  List<Product> productTopup = [];
  Product? selectedProduct;

  InquiryResponse? inquiryAccountResult;
  bool isLoading = false;
  String trxId = ''; // TODO generate local trxid
  Vendor prepaidVendor = Vendor(
    serverId: 0,
    name: 'PLN Prepaid',
    productCode: 'listrik',
    group: 'PLN',
    updatedAt: DateTime.now(),
    productType: groupTopup,
    imageUrl: '',
    title: '',
  );
  final String prepaidInquiryCode = 'CEKPLNPRA';

  // Postpaid product
  final String postpaidInquiryCode = 'CEKPLN';
  final String postpaidPaymentCode = 'PAYPLN';
  InquiryResponse? inquiryResponse;

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
      }
    }
    initDB();
  }

  Future<void> initDB() async {
    var resp = await Api.getProductCriteria(prepaidVendor.productCode);
    ProductCriteriaResponse vendorCriteria =
        ProductCriteriaResponse.fromString(resp.body);

    debugPrint(
        'PurchasePaymentProductScreen ${prepaidVendor.name} /${prepaidVendor.productCode} criteria ${resp.body}');

    Condition<Product> dbCriteria = Product_.status.equals(statusOpen);

    // Parsing criteria to DB { status: !=|1, opr: GRABPAY}}
    for (String key in vendorCriteria.criteria.keys) {
      if (vendorCriteria.criteria[key] != null) {
        String value = vendorCriteria.criteria[key]!;
        var tmp = value.split('|');
        QueryProperty<Product, dynamic>? column;
        String opr = '';
        String search = '';

        if (tmp.length > 1) {
          opr = tmp[0].toLowerCase();
          search = tmp[1];
        } else {
          opr = '=';
          search = tmp[0];
        }

        dbCriteria = productQueryBuilder(dbCriteria, key, opr, search);
      }
    }

    await AppDB.syncProduct();

    final productDB = AppDB.productDB;

    // Product Pulsa
    QueryBuilder<Product> queryPulsa = productDB.query(dbCriteria)
      ..order(Product_.groupName);
    productTopup = queryPulsa.build().find();

    debugPrint(
        'PurchasePaymentProductScreen product size ${productTopup.length}');

    isLoading = false;
    setState(() {});
  }

  FutureOr<Null> _handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  void reset() {
    textController.clear();
    destinationNumber = '';
    selectedProduct = null;
    onModeChange(productMode.prepaid);
    if (prepaidKey.currentState != null) {
      prepaidKey.currentState!.reset();
    }
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

  FutureOr<void> handleError(dynamic e) {
    snackBarDialog(context, e.toString());
    setState(() {
      isLoading = false;
    });
  }

  Future<void> inquiryPrepaidAccount() async {
    // popScreen(context);
    setState(() {
      isLoading = true;
    });
    await Api.inquiryPayment(
      trxId: trxId,
      inquiryCode: prepaidInquiryCode,
      destination: destinationNumber,
    ).then((response) {
      setState(() {
        isLoading = false;
        inquiryAccountResult = InquiryResponse.fromString(response.body);
      });
    }).catchError(handleError);
  }

  Future<void> onProductSelected(Product? value) async {
    if (isValidDestination()) {
      await inquiryPrepaidAccount();
      selectedProduct = value;
      openPayment();
    } else {
      snackBarDialog(context, 'Masukkan nomor tujuan');
    }
  }

  void onInquiryCompleted(InquiryResponse response) {
    inquiryResponse = response;
    openPayment();
  }

  void onDestinationChange(String value) {
    value = value.trim();
    if (prepaidKey.currentState != null) {
      prepaidKey.currentState!.reset();
    }
    if (postpaidKey.currentState != null) {
      postpaidKey.currentState!.reset();
    }
    if (destinationNumber != value && value.length > 3) {
      setState(() {
        destinationNumber = value;
        inquiryResponse = null;
        inquiryAccountResult = null;
      });
    } else if (destinationNumber.isNotEmpty) {
      setState(() {
        destinationNumber = '';
        inquiryResponse = null;
        inquiryAccountResult = null;
      });
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
        if (inquiryAccountResult != null) {
          paymentDesc = inquiryAccountResult!.inquiryDetail;
          paymentDesc += 'Nominal: ${formatNumber(selectedProduct!.nominal)}\n'
              'Harga Beli: ${formatNumber(selectedProduct!.getUserPrice(userBalanceState.level, markup: userBalanceState.markup))}\n';
        } else {
          paymentDesc = 'Produk: PLN Prabayar\n'
              'No Meter / ID Pelanggan: $destinationNumber\n'
              'Nominal: ${formatNumber(selectedProduct!.nominal)}\n'
              'Harga Beli: ${formatNumber(selectedProduct!.getUserPrice(userBalanceState.level, markup: userBalanceState.markup))}\n';
        }
        // if (selectedProduct!.description.isNotEmpty) {
        //   paymentDesc += '\n${selectedProduct!.description}';
        // }
      } else if (selectedMode == productMode.postpaid &&
          inquiryResponse != null) {
        purchaseCode = postpaidPaymentCode;
        items = [
          SummaryItems('Pembayaran Tagihan PLN', inquiryResponse!.amount),
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
          onPaymentConfirmed: onPaymentConfirmed,
        );
      });
    } else {
      snackBarDialog(context, 'Masukkan nomor tujuan');
    }
  }

  bool isValidDestination() {
    return destinationNumber.isNotEmpty;
  }

  bool canOpenPayment() {
    return isValidDestination() &&
        (selectedProduct != null || inquiryResponse != null);
  }

  void onProductChange(Product? value) {
    inquiryResponse = null;
    selectedProduct = value;
    setState(() {});
  }

  Widget buildPrepaidScreen() {
    // return ProductTopup(
    //   key: const PageStorageKey<String>('ProductListrik'),
    //   destination: destinationNumber,
    //   onProductSelected: onProductSelected,
    //   vendor: prepaidVendor,
    // );
    return ProductPayment(
      key: prepaidKey,
      destination: destinationNumber,
      inquiryCode: 'CEKPLNPRA',
      onInquiryCompleted: onInquiryCompleted,
      productCode: selectedProduct == null ? null : selectedProduct!.code,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: 'Listrik'),
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
                        child: Text('Pascabayar'),
                      ),
                    ],
                  ),
                ],
              ),
              TextFormField(
                controller: textController,
                decoration: generateInputDecoration(
                  hint: 'Contoh 1122334455',
                  label: 'Nomor Meter / ID Pelanggan',
                  onClear: destinationNumber.isNotEmpty
                      ? () {
                          textController.clear();
                          onDestinationChange('');
                        }
                      : null,
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
              const SizedBox(height: 10),
              selectedMode == productMode.prepaid
                  ? DropdownSearch<Product>(
                      //mode of dropdown
                      mode: Mode.MENU,
                      //to show search box
                      showSearchBox: false,
                      itemAsString: (item) {
                        return item == null ? '' : item.productName;
                      },
                      // showSelectedItems: true,
                      //list of dropdown items
                      items: productTopup,
                      // label: "Pilih Produk",
                      onChanged: onProductChange,
                      //show selected item
                      selectedItem: null,
                    )
                  : const SizedBox(),
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
