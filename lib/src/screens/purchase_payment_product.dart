import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/api/purchase.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/screens/payment.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/product_payment.dart';
import 'package:miliv2/src/widgets/screen.dart';
import 'package:objectbox/internal.dart';

class PurchasePaymentProductScreen extends StatefulWidget {
  final Vendor vendor;
  final String? destination;

  const PurchasePaymentProductScreen(
      {Key? key, required this.vendor, this.destination})
      : super(key: key);

  @override
  _PurchasePaymentProductScreenState createState() =>
      _PurchasePaymentProductScreenState();
}

class _PurchasePaymentProductScreenState
    extends State<PurchasePaymentProductScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();
  final postpaidKey = GlobalKey<ProductPaymentState>();

  bool isLoading = true;
  String destinationNumber = '';
  InquiryResponse? inquiryResponse;

  List<Product> productPulsa = [];
  Product? selectedProduct;

  @override
  void initState() {
    super.initState();
    destinationNumber = widget.destination ?? '';
    textController.text = widget.destination ?? '';
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initDB();
    });
  }

  Future<void> initDB() async {
    var resp = await Api.getProductCriteria(widget.vendor.productCode);
    ProductCriteriaResponse vendorCriteria =
        ProductCriteriaResponse.fromString(resp.body);

    debugPrint(
        'PurchasePaymentProductScreen ${widget.vendor.name} /${widget.vendor.productCode} criteria ${resp.body}');

    Condition<Product> dbCriteria = Product_.status
        .equals(statusOpen)
        .or(Product_.status.equals(statusClosed));

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
    productPulsa = queryPulsa.build().find();

    debugPrint(
        'PurchasePaymentProductScreen product size ${productPulsa.length}');

    isLoading = false;
    setState(() {});
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
      purchaseCode = selectedProduct != null
          ? selectedProduct!.code
          : widget.vendor.paymentCode;
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
    return destinationNumber.isNotEmpty && selectedProduct != null;
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

  void onProductChange(Product? value) {
    inquiryResponse = null;
    selectedProduct = value;
    setState(() {});
  }

  Widget buildProduct(BuildContext context) {
    return ProductPayment(
      key: postpaidKey,
      destination: destinationNumber,
      inquiryCode: widget.vendor.inquiryCode,
      onInquiryCompleted: onInquiryCompleted,
      productCode: selectedProduct == null ? null : selectedProduct!.code,
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
              DropdownSearch<Product>(
                //mode of dropdown
                mode: Mode.MENU,

                //to show search box
                showSearchBox: true,
                itemAsString: (item) {
                  return item == null ? '' : item.productName;
                },
                // showSelectedItems: true,
                //list of dropdown items
                items: productPulsa,
                // label: "Pilih Produk",
                onChanged: onProductChange,
                //show selected item
                selectedItem: null,
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
