import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'user_config.g.dart';

@JsonSerializable()
class UserConfigResponse {
  @JsonKey(name: 'id')
  late int serverId;

  @JsonKey(name: 'agenid')
  late String userId;

  @JsonKey(name: 'name')
  late String name;

  @JsonKey(name: 'config')
  late Map<String, Object?>? config;

  @JsonKey(name: 'updated_at')
  late DateTime lastUpdate;

  UserConfigResponse();

  factory UserConfigResponse.fromString(String body) =>
      _$UserConfigResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory UserConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$UserConfigResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserConfigResponseToJson(this);
}
