import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/product_payment.dart';
import 'package:miliv2/src/widgets/screen.dart';
import 'package:objectbox/internal.dart';

class PurchasePaymentProductScreen extends StatefulWidget {
  final Vendor vendor;
  final String? destination;
  final String? productCode;

  const PurchasePaymentProductScreen(
      {Key? key, required this.vendor, this.destination, this.productCode})
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

  VendorConfigResponse? vendorConfig;

  Cutoff? cutoff;

  late final int userLevel;
  late final double userMarkup;

  @override
  void initState() {
    super.initState();
    userLevel = userBalanceState.level;
    userMarkup = userBalanceState.markup;
    destinationNumber = widget.destination ?? '';
    textController.text = widget.destination ?? '';
    vendorConfig = widget.vendor.configMap;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() async {
    await initDB();
    if (widget.productCode != null) {
      selectedProduct = productPulsa
          .firstWhere((product) => product.code == widget.productCode!);
    }
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
      ..order(Product_.weight, flags: 1)
      ..order(Product_.groupName)
      ..order(getPriceLevel(userLevel))
      ..order(Product_.productName);
    productPulsa = queryPulsa.build().find();

    debugPrint(
        'PurchasePaymentProductScreen product size ${productPulsa.length}');

    // product code or group from voucher config
    final cutoffDB = AppDB.cutoffDB;
    cutoff = cutoffDB
        .query(Cutoff_.productCode
            .equals(widget.vendor.productCode, caseSensitive: false)
            .or(Cutoff_.productCode
                .equals(widget.vendor.group, caseSensitive: false)))
        .build()
        .findFirst();

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
    return formKey.currentState!.validate();
  }

  void onDestinationChange(String value) {
    value = value.trim();
    if (postpaidKey.currentState != null) {
      postpaidKey.currentState!.reset();
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

  void onProductChange(Product? value) {
    if (postpaidKey.currentState != null) {
      postpaidKey.currentState!.reset();
    }
    inquiryResponse = null;
    setState(() {
      selectedProduct = value;
    });
    isValidDestination();
  }

  Widget buildProduct(BuildContext context) {
    return ProductPayment(
      key: postpaidKey,
      destination: destinationNumber,
      inquiryCode: widget.vendor.inquiryCode,
      onInquiryCompleted: onInquiryCompleted,
      productCode: selectedProduct == null ? '' : selectedProduct!.code,
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

  bool isClosed(Cutoff? cutoff) {
    if (cutoff != null) {
      DateTime now = DateTime.now();
      DateTime utc = now.toUtc();
      DateTime wib = utc.add(const Duration(hours: 7));
      String _wib = DateFormat('HHmm').format(wib);
      int timeWib = parseInt(_wib);

      int startTime = parseInt(cutoff.start);
      int endTime = parseInt(cutoff.end);

      debugPrint('Cutoff $startTime $endTime == $timeWib');

      if (startTime > endTime) {
        return timeWib >= parseInt(cutoff.start) ||
            timeWib < parseInt(cutoff.end);
      } else {
        return timeWib >= parseInt(cutoff.start) &&
            timeWib < parseInt(cutoff.end);
      }
    }

    return false;
  }

  Widget builPopupItem(Product value) {
    return ListTile(
      tileColor: value.promo ? Colors.greenAccent.withOpacity(.2) : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      leading: widget.vendor.getImageUrl().isNotEmpty
          ? CircleAvatar(
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
            )
          : null,
      title: Text(
        value.productName,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle:
          value.description.isNotEmpty || value.status == 2 || isClosed(cutoff)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    value.description.isNotEmpty
                        ? Text(
                            value.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : const SizedBox(),
                    value.status == 2
                        ? Text(
                            'Sedang gangguan',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.red),
                          )
                        : isClosed(cutoff)
                            ? Text(
                                'Sedang cut off',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.red),
                              )
                            : const SizedBox(),
                  ],
                )
              : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          value.promo
              ? Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Text(
                      'PROMO',
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                )
              : const SizedBox(),
          (vendorConfig?.showPrice == true)
              ? Text(
                  formatNumber(
                      value.getUserPrice(userLevel, markup: userMarkup)),
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : const SizedBox(),
        ],
      ),
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
              const SizedBox(height: 10),
              isLoading
                  ? Center(
                      child: Column(
                      children: [
                        Transform.scale(
                          scale: 0.5,
                          child: const CircularProgressIndicator(),
                        ),
                        const Text(
                          'Memuat produk...',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ))
                  : DropdownSearch<Product>(
                      mode: Mode.BOTTOM_SHEET,
                      dropdownSearchDecoration:
                          generateInputDecoration(hint: 'Pilih Produk'),
                      popupItemDisabled: (value) {
                        return value.status != statusOpen || isClosed(cutoff);
                      },
                      popupItemBuilder: (context, value, _) =>
                          builPopupItem(value),
                      maxHeight: 5500,
                      showSearchBox: true,
                      itemAsString: (item) {
                        return item == null ? '' : item.productName;
                      },
                      items: productPulsa,
                      onChanged: onProductChange,
                      selectedItem: selectedProduct,
                      popupSafeArea: const PopupSafeAreaProps(top: true),
                      popupShape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      searchFieldProps: TextFieldProps(
                        padding: const EdgeInsets.only(
                          top: 40,
                          left: 10,
                          right: 10,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          hintText: 'Cari produk...',
                          hintStyle: TextStyle(color: Colors.black54),
                        ),
                      ),
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
