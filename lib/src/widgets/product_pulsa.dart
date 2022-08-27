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
  final int level;
  final Function(Product?) onProductSelected;

  const ProductPulsa(
      {Key? key,
      required this.onProductSelected,
      required this.destination,
      required this.level})
      : super(key: key);

  @override
  _ProductPulsaState createState() => _ProductPulsaState();
}

class _ProductPulsaState extends State<ProductPulsa>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController tabController;

  bool isLoading = true;
  Product? selectedProduct;

  List<Product> productPulsa = [];
  List<Product> productData = [];

  List<String> operatorPulsa = [];
  List<String> operatorData = [];

  late final int userLevel;
  late final double userMarkup;

  @override
  void initState() {
    userLevel = userBalanceState.level;
    userMarkup = userBalanceState.markup;
    super.initState();
    debugPrint('initState product_pulsa');
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
    await AppDB.syncProduct();

    final productDB = AppDB.productDB;
    // Product Pulsa
    QueryBuilder<Product> queryPulsa = productDB.query(Product_.productGroup
        .equals(groupPulsa)
        .and(Product_.status
            .equals(statusOpen)
            .or(Product_.status.equals(statusClosed))))
      ..order(Product_.groupName)
      ..order(Product_.nominal)
      ..order(Product_.productName);
    productPulsa = queryPulsa.build().find();
    // Product Data
    QueryBuilder<Product> queryData = productDB.query(Product_.productGroup
        .equals(groupData)
        .and(Product_.status
            .equals(statusOpen)
            .or(Product_.status.equals(statusClosed))))
      ..order(Product_.groupName)
      ..order(Product_.nominal)
      ..order(Product_.productName);
    productData = queryData.build().find();

    operatorPulsa = productPulsa.map((e) => e.groupName).toList();
    operatorData = productData.map((e) => e.groupName).toList();

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
    return Card(
      child: ListTile(
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
            Text(
              formatNumber(product.getUserPrice(userLevel, markup: userMarkup)),
              style: Theme.of(context).textTheme.bodySmall,
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
        },
      ),
    );
  }

  void _onSelectProduct(Product? value) {
    setState(() {
      selectedProduct = value;
    });

    widget.onProductSelected(value);
  }

  Widget buildPulsaProduct() {
    final filteredProduct = filterByPrefix(productPulsa);
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
              style: Theme.of(context).textTheme.bodyMedium),
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

  Widget buildDataProduct() {
    final filteredProduct = filterByPrefix(productData);
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
              style: Theme.of(context).textTheme.bodyMedium),
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
      key: const PageStorageKey<String>('listData'),
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        TabBar(
          key: const PageStorageKey<String>('tabPulsa'),
          controller: tabController,
          tabs: [
            Tab(
              child: Text(
                'Pulsa',
                style: Theme.of(context).textTheme.button,
              ),
            ),
            Tab(
              child: Text(
                'Data',
                style: Theme.of(context).textTheme.button,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              buildPulsaProduct(),
              buildDataProduct(),
            ],
          ),
        ),
      ],
      // child: _buildPrepaidProduct(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
