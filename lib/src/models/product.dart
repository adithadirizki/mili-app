import 'package:miliv2/src/api/product.dart';
import 'package:objectbox/objectbox.dart';

@Entity(uid: 8995185104894460759)
class Product {
  int id;
  String code;
  String productName;
  String description;
  String groupName;
  double nominal;
  double priceLevel1;
  double priceLevel2;
  double priceLevel3;
  double priceLevel4;
  double priceLevel5;
  double priceLevel6;
  double priceLevel7;
  double priceLevel8;
  double priceLevel9;
  double priceLevel10;
  double markup;
  // double userPrice;
  double? priceSetting;
  int status;
  int voucherType; // jenis
  int productGroup; // kelompok
  bool promo;
  String prefix;
  int? weight;
  @Property(uid: 7091024253216099436, type: PropertyType.date)
  DateTime updatedDate;

  Product(
      {this.id = 0,
      required this.code,
      required this.productName,
      required this.groupName,
      // required this.userPrice,
      required this.markup,
      this.priceLevel1 = 0,
      this.priceLevel2 = 0,
      this.priceLevel3 = 0,
      this.priceLevel4 = 0,
      this.priceLevel5 = 0,
      this.priceLevel6 = 0,
      this.priceLevel7 = 0,
      this.priceLevel8 = 0,
      this.priceLevel9 = 0,
      this.priceLevel10 = 0,
      this.description = '',
      this.nominal = 0,
      required this.status,
      required this.voucherType,
      required this.productGroup,
      this.promo = false,
      this.prefix = '',
      this.weight = 0,
      required this.updatedDate,
      this.priceSetting});

  factory Product.fromResponse(ProductResponse response) => Product(
        code: response.code,
        productName: response.productName,
        groupName: response.groupName,
        description: response.description ?? '',
        status: response.status,
        voucherType: response.voucherType,
        productGroup: response.productGroup,
        promo: response.promo,
        prefix: response.prefix ?? '',
        weight: response.weight,
        nominal: response.nominal,
        // userPrice: response.price,
        markup: response.markup,
        priceLevel1: response.priceLevel1,
        priceLevel2: response.priceLevel2,
        priceLevel3: response.priceLevel3,
        priceLevel4: response.priceLevel4,
        priceLevel5: response.priceLevel5,
        priceLevel6: response.priceLevel6,
        priceLevel7: response.priceLevel7,
        priceLevel8: response.priceLevel8,
        priceLevel9: response.priceLevel9,
        priceLevel10: response.priceLevel10,
        updatedDate: response.updatedAt,
      );

  double getUserPrice(int userLevel, {double? markup}) {
    double price = 0;
    switch (userLevel) {
      case 1:
        price = priceLevel1;
        break;
      case 2:
        price = priceLevel2;
        break;
      case 3:
        price = priceLevel3;
        break;
      case 4:
        price = priceLevel4;
        break;
      case 5:
        price = priceLevel5;
        break;
      case 6:
        price = priceLevel6;
        break;
      case 7:
        price = priceLevel7;
        break;
      case 8:
        price = priceLevel8;
        break;
      case 9:
        price = priceLevel9;
        break;
      case 10:
        price = priceLevel10;
        break;
    }
    if (price == 1) price = 0;
    return price + (markup ?? 0);
  }
}

@Entity()
class Cutoff {
  int id;
  String productCode;
  String? notes;
  String start;
  String end;

  Cutoff({
    this.id = 0,
    required this.productCode,
    this.notes,
    required this.start,
    required this.end
  });

  factory Cutoff.fromResponse(CutoffResponse response) => Cutoff(
    productCode: response.productCode,
    notes: response.notes,
    start: response.start,
    end: response.end
  );
}
