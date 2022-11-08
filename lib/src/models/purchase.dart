import 'package:miliv2/src/api/purchase.dart';
import 'package:objectbox/objectbox.dart';

@Entity(uid: 4339777652162826620)
class PurchaseHistory {
  int id;
  @Property(uid: 3142129608704666837)
  int serverId;
  String userId;
  String productCode;
  String productName;
  String groupName;
  String destination;
  @Property(type: PropertyType.date)
  DateTime transactionDate;
  String status;
  double price;
  Map<String, dynamic>? productConfig; // TODO ganti ke model Vendor
  String? productDetail;
  StructDetailResponse? purchaseStruct;

  PurchaseHistory({
    this.id = 0,
    required this.userId,
    required this.serverId,
    required this.productCode,
    required this.productName,
    required this.groupName,
    required this.destination,
    required this.transactionDate,
    required this.status,
    required this.price,
    this.productConfig,
    this.productDetail,
    this.purchaseStruct,
  });

  factory PurchaseHistory.fromResponse(PurchaseHistoryResponse response) =>
      PurchaseHistory(
        userId: response.userId,
        serverId: response.serverId,
        productCode: response.productCode,
        productName: response.productName,
        groupName: response.groupName,
        destination: response.destination,
        transactionDate: response.transactionDate,
        status: response.status,
        price: response.price,
        productConfig: response.productConfig != null
            ? response.productConfig!.toJson()
            : null,
        productDetail: response.productDetail,
        purchaseStruct: response.purchaseStruct,
      );

  bool get isSuccess => status.toUpperCase() == 'SUCCESSED';
  bool get isFailed => status.toUpperCase() == 'FAILED';
  bool get isPending => status.toUpperCase() == 'PENDING';
}
