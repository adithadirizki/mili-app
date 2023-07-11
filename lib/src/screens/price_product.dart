import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:objectbox/objectbox.dart';

class PriceProductScreen extends StatefulWidget {
  final String title;
  final String? vendorGroup;
  final List<String>? productGroups;

  const PriceProductScreen(
      {Key? key, this.vendorGroup, this.productGroups, required this.title})
      : super(key: key);

  @override
  _PriceProductScreenState createState() => _PriceProductScreenState();
}

class _PriceProductScreenState extends State<PriceProductScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TextEditingController queryController = TextEditingController();
  late TabController tabController;

  bool isLoading = true;
  String query = '';
  Product? selectedProduct;

  List<Product> productPulsa = [];
  // List<Product> productData = [];

  final priceController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  late final int userLevel;
  late final double userMarkup;

  @override
  void initState() {
    userLevel = userBalanceState.level;
    userMarkup = 0; // TODO ambil dari userBalanceState.markup;
    super.initState();
    debugPrint('initState price_product');
    tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initDB();
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> initDB() async {
    // await AppDB.syncProduct();
    // await AppDB.syncVendor();
    await AppDB.syncPriceSetting();

    final productDB = AppDB.productDB;

    List<String> productGroups = [];

    if (widget.productGroups != null) {
      productGroups = widget.productGroups!;
    } else if (widget.vendorGroup != null) {
      QueryBuilder<Vendor> queryVendor =
          AppDB.vendorDB.query(Vendor_.group.equals(widget.vendorGroup!));
      var vendorList = queryVendor.build().find();
      for (var vendor in vendorList) {
        if (vendor.productGroupNameList != null) {
          productGroups.addAll(vendor.productGroupNameList!);
        } else {
          debugPrint(
              'Vendor ${vendor.name} doesn\'t have productGroupNameList');
        }
      }
    }

    debugPrint('Product Group $productGroups');

    // Product Pulsa
    QueryBuilder<Product> queryPulsa = productDB.query(Product_.groupName
        .oneOf(productGroups)
        .and(Product_.status
            .equals(statusOpen)
            .or(Product_.status.equals(statusClosed))))
      ..order(Product_.weight, flags: 1)
      ..order(Product_.groupName)
      ..order(getPriceLevel(userLevel))
      ..order(Product_.productName);
    productPulsa = queryPulsa.build().find();

    // // Product Data
    // QueryBuilder<Product> queryData = productDB.query(Product_.productGroup
    //     .equals(groupData)
    //     .and(Product_.status
    //         .equals(statusOpen)
    //         .or(Product_.status.equals(statusClosed))))
    //   ..order(Product_.groupName);
    // productData = queryData.build().find();

    isLoading = false;
    setState(() {});
  }

  Iterable<Product> filterByQuery(List<Product> productList) {
    return productList.where((product) {
      double price = product.getUserPrice(userLevel);
      if (product.code.startsWith('CEK') ||
          (!product.code.startsWith('PAY') && price <= 0)) {
        return false;
      }
      return query.isEmpty
          ? true
          : (product.groupName.toUpperCase().contains(query.toUpperCase()) ||
              product.productName.toUpperCase().contains(query.toUpperCase()) ||
              product.description.toUpperCase().contains(query.toUpperCase()));
    });
  }

  FutureOr<void> _handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  void _onSelectProduct(Product? value) {
    setState(() {
      selectedProduct = value;
    });
  }

  Future<void> showPopupSetting(Product product) async {
    var value =
        formatNumber(product.getUserPrice(userLevel, markup: userMarkup));
    priceController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(
        offset: value.length,
      ),
    );
    showDialog<Widget>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          // title: const Text('Nama'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: priceController,
                    autofocus: true,
                    decoration:
                        generateInputDecoration(hint: '0', label: 'Harga Jual'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      var number = parseDouble(value);
                      if (number > 10000000) {
                        number = 1000000;
                      } else if (number < 0) {
                        number = 0;
                      }
                      //
                      value = formatNumber(number);
                      priceController.value = TextEditingValue(
                        text: value,
                        selection: TextSelection.collapsed(
                          offset: value.length,
                        ),
                      );
                    },
                    validator: (value) {
                      var number = parseDouble(value ?? '');
                      // if (number > 10000000) {
                      //   number = 1000000;
                      // } else if (number < 0) {
                      //   number = 0;
                      // }
                      if (number <= 0) {
                        return 'Masukkan Harga';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                priceController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: Theme.of(context).textTheme.button,
              ),
            ),
            TextButton(
              onPressed: () async {
                var success = await updatePrice(
                    product, parseDouble(priceController.text));
                if (success) {
                  await Navigator.of(context).maybePop();
                }
              },
              child: Text(
                'Simpan',
                style: Theme.of(context).textTheme.button,
              ),
            )
          ],
        );
      },
    );
  }

  Future<bool> updatePrice(Product product, double price) async {
    if (formKey.currentState!.validate()) {
      await Api.updatePriceSetting(product.code, price).then((response) {
        if (response.statusCode == 200) {
          snackBarDialog(context, 'Berhasil menyimpan harga');
          AppDB.syncPriceSetting(); // FIXME Update current price ??
        }
      }).catchError(_handleError);
      priceController.clear();
      return true;
    }
    return false;
  }

  Widget itemBuilder(Product product) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        // leading: CircleAvatar(
        //   radius: 18.0,
        //   backgroundImage: getProductLogo(product),
        //   backgroundColor: Colors.transparent,
        // ),
        title: Text(
          product.productName,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: product.description.isNotEmpty
            ? Text(
                product.description,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        enabled: product.status == statusOpen,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatNumber(
                      product.getUserPrice(userLevel, markup: userMarkup)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 5),
                Text(
                  product.priceSetting == null
                      ? '-'
                      : formatNumber(product.priceSetting ?? 0),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Radio<Product>(
              onChanged: _onSelectProduct,
              groupValue: selectedProduct,
              value: product,
            ),
          ],
        ),
        onTap: () {
          _onSelectProduct(product);
          showPopupSetting(product);
        },
      ),
    );
  }

  Widget buildListPulsa() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }
    final filteredProduct = filterByQuery(productPulsa);
    final groups = filteredProduct.map((e) => e.groupName).toList();

    Widget groupContainer(int index) {
      var product = filteredProduct.elementAt(index);
      final firstIndex = groups.indexOf(product.groupName);

      if (firstIndex == index) {
        return Container(
          padding:
          const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          alignment: Alignment.centerLeft,
          child: Text(product.groupName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        );
      } else {
        return Container();
      }
    }

    if (filteredProduct.isEmpty) {
      return const Center(
        child: Text('-- produk kosong --'),
      );
    }
    return ListView.builder(
      key: const PageStorageKey<String>('listPulsa'),
      physics: const ClampingScrollPhysics(),
      itemCount: filteredProduct.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            groupContainer(index),
            itemBuilder(filteredProduct.elementAt(index))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar2(
        title: widget.title,
      ),
      body: Column(
        children: [
          TextField(
            controller: queryController,
            decoration: generateInputDecoration(
              hint: 'Cari Produk',
              label: null,
              onClear: query.isNotEmpty
                  ? () {
                      queryController.clear();
                      query = '';
                      setState(() {});
                    }
                  : null,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              outlineBorder: true,
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              query = value;
              setState(() {});
            },
          ),
          Expanded(
            child: buildListPulsa(),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
