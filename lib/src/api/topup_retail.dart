import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'topup_retail.g.dart';

@JsonSerializable()
class TopupRetailHistoryResponse {
  @JsonKey(name: 'id')
  late final int id;

  @JsonKey(name: 'agenid')
  late final String agenid;

  @JsonKey(name: 'nohp')
  late final String nohp;

  @JsonKey(name: 'customer_name')
  late final String customer_name;

  @JsonKey(name: 'nominal')
  late final double nominal;

  @JsonKey(name: 'additionalfee')
  late final double? additionalfee;

  @JsonKey(name: 'payment_reff')
  late final int? payment_reff;

  @JsonKey(name: 'kode_pembayaran')
  late final String? kode_pembayaran;

  @JsonKey(name: 'channel')
  late final String channel;

  @JsonKey(name: 'status')
  late final int status;

  @JsonKey(name: 'sn')
  late final String? sn;

  @JsonKey(name: 'tanggal_bayar')
  late final DateTime? tanggal_bayar;

  @JsonKey(name: 'created_at')
  late final DateTime created_at;

  TopupRetailHistoryResponse();

  factory TopupRetailHistoryResponse.fromString(String body) =>
      _$TopupRetailHistoryResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory TopupRetailHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$TopupRetailHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopupRetailHistoryResponseToJson(this);
}
