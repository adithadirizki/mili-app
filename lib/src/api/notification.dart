import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationResponse {
  @JsonKey(name: 'id')
  late int serverId;

  @JsonKey(name: 'object')
  late String? object;

  @JsonKey(name: 'object_id')
  late int? objectId;

  @JsonKey(name: 'title')
  late String title;

  @JsonKey(name: 'body')
  late String body;

  @JsonKey(name: 'reference')
  late String? reference;

  @JsonKey(name: 'url')
  late String? url;

  @JsonKey(name: 'agenid')
  late String userId;

  @JsonKey(name: 'channel')
  late String? channel;

  @JsonKey(name: 'updated_at')
  late final DateTime notificationDate;

  NotificationResponse();

  factory NotificationResponse.fromString(String body) =>
      _$NotificationResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}
