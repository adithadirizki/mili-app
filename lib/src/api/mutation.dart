import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'mutation.g.dart';

@JsonSerializable()
class BalanceMutationResponse {
  @JsonKey(name: 'id')
  late int serverId;

  @JsonKey(name: 'agenid')
  late String userId;

  @JsonKey(name: 'tanggal')
  late final DateTime mutationDate;

  @JsonKey(name: 'ket')
  late String description;

  @JsonKey(name: 'vtype')
  late String? productCode;

  @JsonKey(name: 'transaction_name')
  late String? productName;

  @JsonKey(name: 'detail')
  late String? productDetail;

  @JsonKey(name: 'debet')
  late double debitAmount;

  @JsonKey(name: 'kredit')
  late double creditAmount;

  @JsonKey(name: 'lastbalance')
  late double startBalance;

  @JsonKey(name: 'currbalance')
  late double endBalance;

  BalanceMutationResponse();

  factory BalanceMutationResponse.fromString(String body) =>
      _$BalanceMutationResponseFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory BalanceMutationResponse.fromJson(Map<String, dynamic> json) =>
      _$BalanceMutationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceMutationResponseToJson(this);
}

@JsonSerializable()
class CreditMutationResponse {
  @JsonKey(name: 'id')
  late int serverId;

  @JsonKey(name: 'agenid')
  late String userId;

  @JsonKey(name: 'created_at')
  late final DateTime mutationDate;

  @JsonKey(name: 'description')
  late String description;

  @JsonKey(name: 'vtype')
  late String? productCode;

  @JsonKey(name: 'transaction_name')
  late String? productName;

  @JsonKey(name: 'detail')
  late String? productDetail;

  @JsonKey(name: 'debet')
  late double debitAmount;

  @JsonKey(name: 'kredit')
  late double creditAmount;

  @JsonKey(name: 'lastbalance')
  late double startBalance;

  @JsonKey(name: 'currbalance')
  late double endBalance;

  CreditMutationResponse();

  factory CreditMutationResponse.fromString(String body) =>
      _$CreditMutationResponseFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory CreditMutationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditMutationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreditMutationResponseToJson(this);
}
