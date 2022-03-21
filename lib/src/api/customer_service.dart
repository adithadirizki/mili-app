import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'customer_service.g.dart';

@JsonSerializable()
class CustomerServiceResponse {
  @JsonKey(name: 'id')
  late int serverId;

  @JsonKey(name: 'agenid')
  late String userId;

  @JsonKey(name: 'sender')
  late String senderId;

  @JsonKey(name: 'tanggal')
  late DateTime messageDate;

  @JsonKey(name: 'isi')
  late String message;

  @JsonKey(name: 'status')
  late int status;

  @JsonKey(name: 'photo')
  late String? photo;

  @JsonKey(name: 'user')
  late Map<String, dynamic>? userDetail;

  CustomerServiceResponse();

  factory CustomerServiceResponse.fromString(String body) =>
      _$CustomerServiceResponseFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory CustomerServiceResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerServiceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerServiceResponseToJson(this);
}
