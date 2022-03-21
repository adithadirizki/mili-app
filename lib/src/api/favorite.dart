import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'favorite.g.dart';

@JsonSerializable()
class FavoriteResponse {
  @JsonKey(name: 'id')
  late int serverId;

  @JsonKey(name: 'agenid')
  late String userId;

  @JsonKey(name: 'name')
  late String? name;

  @JsonKey(name: 'vtype')
  late String productCode;

  @JsonKey(name: 'opr')
  late String? groupName;

  @JsonKey(name: 'transaction_number')
  late String destination;

  @JsonKey(name: 'voucher_name')
  late String? productName;

  @JsonKey(name: 'updated_at')
  late final DateTime updatedAt;

  FavoriteResponse();

  factory FavoriteResponse.fromString(String body) =>
      _$FavoriteResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory FavoriteResponse.fromJson(Map<String, dynamic> json) =>
      _$FavoriteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteResponseToJson(this);
}
