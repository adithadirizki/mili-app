import 'package:flutter/material.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/utils/product.dart';

class ProductPulsa extends StatefulWidget {
  final String destination;
  final String? selectedProductCode;
  final int level;
  final Function(Product?) onProductSelected;

  const ProductPulsa(
      {Key? key,
      required this.onProductSelected,
      required this.destination,
      this.selectedProductCode,
      required this.level})
      : super(key: key);

  @override
  _ProductPulsaState createState() => _ProductPulsaState();
}

class _ProductPulsaState extends State<ProductPulsa>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  Product? selectedProduct;

  List<Product> products = [];
  List<String> operators = [];

  late final int userLevel;
  late final double userMarkup;

  @override
  void initState() {
    userLevel = userBalanceState.level;
    userMarkup = userBalanceState.markup;
    super.initState();
    debugPrint('initState product_pulsa');
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initDB();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initDB() async {
    await AppDB.syncProduct();

    final productDB = AppDB.productDB;
    // Product Pulsa
    QueryBuilder<Product> queryPulsa = productDB.query(Product_.productGroup
        .equals(groupPulsa)
        .and(Product_.status
            .equals(statusOpen)
            .or(Product_.status.equals(statusClosed))))
      ..order(Product_.weight, flags: 1)
      ..order(Product_.groupName)
      ..order(getPriceLevel(userLevel))
      ..order(Product_.productName);
    products = queryPulsa.build().find();

    operators = products.map((e) => e.groupName).toList();

    if (widget.selectedProductCode != null) {
      selectedProduct =
          products.firstWhere((e) => e.code == widget.selectedProductCode);
      widget.onProductSelected(selectedProduct);
    }

    isLoading = false;
    setState(() {});
  }

  Iterable<Product> filterByPrefix(List<Product> productList) {
    var level = widget.level;
    String prefix = getDestinationPrefix(widget.destination);
    debugPrint('Number prefix $prefix level $level');
    return productList.where((product) {
      double price = product.getUserPrice(userLevel);
      if (price <= 1) {
        return false;
      }
      List<String> allowedPrefix =
          product.prefix.isNotEmpty ? product.prefix.split(',') : List.empty();
      // debugPrint('Number prefix ${element.productName} ${allowedPrefix}');
      if (allowedPrefix.isNotEmpty) {
        return allowedPrefix.contains(prefix);
      }
      return true;
    });
  }

  Widget itemBuilder(Product product) {
    return Stack(
      children: [
        Card(
          child: ListTile(
            tileColor:
                product.promo ? Colors.greenAccent.withOpacity(.2) : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            leading: CircleAvatar(
              radius: 18.0,
              backgroundImage: getProductLogo(product),
              backgroundColor: Colors.transparent,
            ),
            title: Text(
              product.productName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: product.description.isNotEmpty || product.status == 2
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      product.description.isNotEmpty
                          ? Text(product.description,
                              style: Theme.of(context).textTheme.bodySmall)
                          : const SizedBox(
                              height: 0,
                            ),
                      product.status == 2
                          ? Text('Sedang gangguan',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.red))
                          : const SizedBox(
                              height: 0,
                            ),
                    ],
                  )
                : null,
            enabled: product.status == statusOpen,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatNumber(
                      product.getUserPrice(userLevel, markup: userMarkup)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Radio<Product>(
                  onChanged: (value) =>
                      product.status == 2 ? null : _onSelectProduct(value),
                  groupValue: selectedProduct,
                  value: product,
                ),
                // Icon(Icons.camera_alt_outlined),
              ],
            ),
            onTap: () => product.status == 2 ? null : _onSelectProduct(product),
          ),
        ),
        product.promo
            ? Positioned(
                child: Container(
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
                ),
                top: 0,
                right: 0,
              )
            : const SizedBox(),
      ],
    );
  }

  void _onSelectProduct(Product? value) {
    setState(() {
      selectedProduct = value;
    });

    widget.onProductSelected(value);
  }

  Widget buildProduct() {
    final filteredProduct = filterByPrefix(products);
    final groups = filteredProduct.map((e) => e.groupName).toList();

    Widget groupContainer(int index) {
      var product = filteredProduct.elementAt(index);
      final firstIndex = groups.indexOf(product.groupName);

      if (firstIndex == index) {
        return Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          alignment: Alignment.centerLeft,
          child: Text(product.groupName,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        );
      } else {
        return Container();
      }
    }

    if (filteredProduct.isEmpty) {
      return Center(
        child: Text(
          'Layanan tidak tersedia',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
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

  bool isValidDestination() {
    return widget.destination.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Build product_pulsa ${widget.destination}');

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    if (!isValidDestination()) {
      return Container(
        alignment: Alignment.topCenter,
        child: Text(
          'Masukkan nomor ponsel untuk memilih produk',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return buildProduct();
  }

  @override
  bool get wantKeepAlive => true;
}
