import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miliv2/objectbox.g.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/database/database.dart';
import 'package:miliv2/src/models/product.dart';
import 'package:miliv2/src/models/vendor.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/utils/product.dart';
import 'package:objectbox/internal.dart';

class ProductTopup extends StatefulWidget {
  final String destination;
  final Function(Product?) onProductSelected;
  final Vendor vendor;

  const ProductTopup({
    Key? key,
    required this.onProductSelected,
    required this.destination,
    required this.vendor,
  }) : super(key: key);

  @override
  _ProductTopupState createState() => _ProductTopupState();
}

class _ProductTopupState extends State<ProductTopup>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  Product? selectedProduct;

  Cutoff? cutoff;

  List<Product> productTopup = [];

  late final int userLevel;
  late final double userMarkup;

  @override
  void initState() {
    userLevel = userBalanceState.level;
    userMarkup = userBalanceState.markup;
    super.initState();
    debugPrint('initState ProductTopup');
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initDB();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initDB() async {
    var resp = await Api.getProductCriteria(widget.vendor.productCode);
    ProductCriteriaResponse vendorCriteria =
        ProductCriteriaResponse.fromString(resp.body);

    debugPrint(
        'ProductTopup ${widget.vendor.name} /${widget.vendor.productCode} criteria ${resp.body}');

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

    // product code or group from voucher config
    final cutoffDB = AppDB.cutoffDB;
    cutoff = cutoffDB.query(Cutoff_.productCode.equals(widget.vendor.productCode)
        .or(Cutoff_.productCode.equals(widget.vendor.group))).build().findFirst();

    await AppDB.syncProduct();

    final productDB = AppDB.productDB;

    // Product Pulsa
    QueryBuilder<Product> queryProduct = productDB.query(dbCriteria)
      ..order(Product_.groupName)
      ..order(Product_.nominal)
      ..order(Product_.productName);
    productTopup = queryProduct.build().find();

    debugPrint('ProductTopup product size ${productTopup.length}');

    isLoading = false;
    setState(() {});
  }

  Iterable<Product> filterByPrefix(List<Product> productList) {
    String prefix = getDestinationPrefix(widget.destination);
    debugPrint('Number prefix $prefix level $userLevel');
    return productList.where((product) {
      double price = product.getUserPrice(userLevel);
      if (price <= 1) {
        return false;
      }
      List<String> allowedPrefix =
          product.prefix.isNotEmpty ? product.prefix.split(',') : List.empty();
      if (allowedPrefix.isNotEmpty) {
        return allowedPrefix.contains(prefix);
      }
      return true;
    });
  }

  bool isClose() {
    DateTime now = DateTime.now();
    DateTime utc = now.toUtc();
    DateTime wib = utc.add(const Duration(hours: 7));
    String _wib = DateFormat('HHmm').format(wib);
    int timeWib = parseInt(_wib);

    if (cutoff != null) {
      if (timeWib > parseInt(cutoff?.start ?? '') || timeWib < parseInt(cutoff?.end ?? '')) {
        return true;
      }
    }

    return false;
  }

  Widget info() {
    if (cutoff == null || cutoff?.notes == null) return Container();

    return Container(
      color: AppColors.blue4.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [Text(cutoff?.notes ?? '', style: const TextStyle(fontWeight: FontWeight.w500, height: 1.5))],
            ),
          )
        ],
      ),
    );
  }

  Widget itemBuilder(Product product) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.only(
            right: 10,
            left: (widget.vendor.getImageUrl().isNotEmpty ? 10 : 20),
            top: 5,
            bottom: 5),
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
                            // colorFilter:
                            //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
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
          product.productName,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: product.description.isNotEmpty || product.status == 2 || isClose() ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product.description.isNotEmpty ? Text(product.description, style: Theme.of(context).textTheme.bodySmall) : SizedBox(height: 0,),
            product.status == 2
                ? Text('Sedang gangguan', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red))
                : isClose()
                ? Text('Sedang cut off', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red))
                : const SizedBox(height: 0,),
          ],
        ) : null,
        enabled: product.status == statusOpen && isClose() == false,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatNumber(product.getUserPrice(userLevel, markup: userMarkup)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Radio<Product>(
              onChanged: (value) => product.status == 2 || isClose() ? null : _onSelectProduct(value),
              groupValue: selectedProduct,
              value: product,
            ),
          ],
        ),
        onTap: () => product.status == 2 || isClose() ? null : _onSelectProduct(product),
      ),
    );
  }

  void _onSelectProduct(Product? value) {
    setState(() {
      selectedProduct = value;
    });

    widget.onProductSelected(value);
  }

  bool isValidDestination() {
    return widget.destination.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    var filteredProduct = filterByPrefix(productTopup);

    if (filteredProduct.isEmpty) {
      return const Center(
        child: Text('-- produk kosong --'),
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('listProduct'),
      physics: const ClampingScrollPhysics(),
      itemCount: filteredProduct.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return info();
        }
        index--;
        return itemBuilder(filteredProduct.elementAt(index));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
