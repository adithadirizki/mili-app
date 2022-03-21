import 'package:miliv2/src/api/customer_service.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:objectbox/objectbox.dart';

@Entity(uid: 3510721631980598728)
class CustomerService {
  int id;
  int serverId;
  String userId;
  String senderId;
  @Property(type: PropertyType.date)
  DateTime messageDate;
  String message;
  int status;
  String? photo;

  CustomerService({
    this.id = 0,
    required this.serverId,
    required this.userId,
    required this.senderId,
    required this.messageDate,
    required this.message,
    this.status = 0,
    this.photo,
  });

  factory CustomerService.fromResponse(CustomerServiceResponse response) =>
      CustomerService(
        serverId: response.serverId,
        userId: response.userId,
        senderId: response.senderId,
        messageDate: response.messageDate,
        message: response.message,
        status: response.status,
        photo: response.photo,
      );

  bool get isOwnMessage => userId == senderId;

  String? get photoUrl =>
      photo == null ? null : AppConfig.baseUrl + '/' + photo!;
}
