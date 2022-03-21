import 'package:miliv2/src/api/favorite.dart';
import 'package:objectbox/objectbox.dart';

@Entity(uid: 1350449791395058203)
class Favorite {
  int id;
  int serverId;
  String userId;
  String name;
  String productCode;
  String groupName;
  String destination;
  @Property(type: PropertyType.date)
  DateTime updatedDate;

  Favorite({
    this.id = 0,
    required this.serverId,
    required this.userId,
    required this.name,
    required this.productCode,
    required this.groupName,
    required this.destination,
    required this.updatedDate,
  });

  factory Favorite.fromResponse(FavoriteResponse response) => Favorite(
        serverId: response.serverId,
        userId: response.userId,
        name: response.name ?? '',
        productCode: response.productCode,
        groupName: response.groupName ?? '',
        destination: response.destination,
        updatedDate: response.updatedAt,
      );
}
