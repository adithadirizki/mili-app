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
import 'package:miliv2/src/screens/contacts.dart';
import 'package:miliv2/src/screens/payment.dart';
import 'package:miliv2/src/services/onesignal.dart';
import 'package:miliv2/src/theme/colors.dart';
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

  late final int userLevel;
  late final double userMarkup;

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
    userLevel = userBalanceState.level;
    userMarkup = userBalanceState.markup;
    super.initState();
    destinationNumber = widget.destination ?? '';
    textController.text = widget.destination ?? '';
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() async {
    await initDB();
    if (widget.productCode != null) {
      if (widget.productCode!.startsWith('PAY')) {
        onModeChange(productMode.postpaid);
      } else {
        selectedProduct = productTopup
            .firstWhere((product) => product.code == widget.productCode!);
      }
    }
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

    // Product Topup
    QueryBuilder<Product> queryProduct = productDB.query(dbCriteria)
      ..order(Product_.groupName)
      ..order(Product_.nominal)
      ..order(Product_.productName);
    productTopup = queryProduct.build().find();
    productTopup = filterProduct(productTopup).toList();

    debugPrint(
        'PurchasePaymentProductScreen product size ${productTopup.length}');

    isLoading = false;
    setState(() {});
  }

  Iterable<Product> filterProduct(List<Product> productList) {
    return productList.where((product) {
      double price = product.getUserPrice(userLevel);
      return price > 1;
    });
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

  // FutureOr<void> handleError(dynamic e) {
  //   snackBarDialog(context, e.toString());
  //   setState(() {
  //     isLoading = false;
  //   });
  // }
  //
  // Future<void> inquiryPrepaidAccount() async {
  //   // popScreen(context);
  //   setState(() {
  //     isLoading = true;
  //   });
  //   await Api.inquiryPayment(
  //     trxId: trxId,
  //     inquiryCode: prepaidInquiryCode,
  //     destination: destinationNumber,
  //   ).then((response) {
  //     setState(() {
  //       isLoading = false;
  //       inquiryAccountResult = InquiryResponse.fromString(response.body);
  //     });
  //   }).catchError(handleError);
  // }
  //
  // Future<void> onProductSelected(Product? value) async {
  //   if (isValidDestination()) {
  //     await inquiryPrepaidAccount();
  //     selectedProduct = value;
  //     openPayment();
  //   } else {
  //     snackBarDialog(context, 'Masukkan nomor tujuan');
  //   }
  // }

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
    if (destinationValidator(value) == null) {
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
    isValidDestination();
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

    // track trx pln
    Map<String, dynamic> tags = await AppOnesignal.getTags();
    var _tags = {
      'last_transaction': DateTime
          .now()
          .millisecondsSinceEpoch,
      'pln': parseInt(tags['pln']?.toString() ?? '0') + 1,
    };
    AppOnesignal.setTags(_tags);
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
    return formKey.currentState!.validate();
  }

  bool canOpenPayment() {
    return isValidDestination() &&
        (selectedProduct != null || inquiryResponse != null);
  }

  void onProductChange(Product? value) {
    inquiryResponse = null;
    selectedProduct = value;
    setState(() {});
    isValidDestination();
  }

  Widget buildPrepaidScreen() {
    return ProductPayment(
      key: prepaidKey,
      destination: destinationNumber,
      inquiryCode: prepaidInquiryCode,
      onInquiryCompleted: onInquiryCompleted,
      productCode: selectedProduct == null ? '' : selectedProduct!.code,
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
    } else if ((value.length < 5) || (value.length > 20)) {
      return 'Nomor tidak sesuai ';
    }
    return null;
  }

  String? productValidator(Product? value) {
    if (value == null) {
      return 'Pilih Produk';
    }
    return null;
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
              const SizedBox(height: 10),
              selectedMode == productMode.prepaid
                  ? DropdownSearch<Product>(
                      //mode of dropdown
                      mode: Mode.MENU,
                      //to show search box
                      showSearchBox: false,
                      itemAsString: (item) {
                        return item == null
                            ? ''
                            : '${item.productName} (${formatNumber(item.getUserPrice(userLevel))})';
                      },
                      // showSelectedItems: true,
                      //list of dropdown items
                      items: productTopup,
                      // label: "Pilih Produk",
                      onChanged: onProductChange,
                      //show selected item
                      selectedItem: selectedProduct,
                      validator: productValidator,
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
