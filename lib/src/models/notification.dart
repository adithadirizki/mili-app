import 'package:miliv2/src/api/notification.dart';
import 'package:objectbox/objectbox.dart';

@Entity(uid: 3529222973951921076)
class Notification {
  int id;
  int serverId;
  String? object;
  int? objectId;
  String title;
  String body;
  String? reference;
  String? url;
  String userId;
  String? channel;
  @Property(type: PropertyType.date)
  DateTime notificationDate;

  Notification({
    this.id = 0,
    required this.serverId,
    required this.object,
    required this.objectId,
    required this.title,
    required this.body,
    this.reference,
    this.url,
    required this.userId,
    this.channel,
    required this.notificationDate,
  });

  factory Notification.fromResponse(NotificationResponse response) =>
      Notification(
        serverId: response.serverId,
        object: response.object,
        objectId: response.objectId,
        title: response.title,
        body: response.body,
        reference: response.reference,
        url: response.url,
        userId: response.userId,
        channel: response.channel,
        notificationDate: response.notificationDate,
      );
}
