import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'topup.g.dart';

@JsonSerializable()
class BankInfo {
  @JsonKey(name: 'bank_name')
  final String bankName;

  @JsonKey(name: 'image')
  final String image;

  @JsonKey(name: 'account_name')
  final String accountName;

  @JsonKey(name: 'account_number')
  final String accountNumber;

  BankInfo(this.bankName, this.image, this.accountName, this.accountNumber);

  factory BankInfo.fromString(String body) =>
      _$BankInfoFromJson(json.decode(body) as Map<String, dynamic>);

  factory BankInfo.fromJson(Map<String, dynamic> json) =>
      _$BankInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BankInfoToJson(this);
}

@JsonSerializable()
class TopupInfoResponse {
  @JsonKey(name: 'notes')
  final String notes;

  @JsonKey(name: 'min_amount')
  final double minAmount;

  @JsonKey(name: 'max_amount')
  final double maxAmount;

  @JsonKey(name: 'min_topup')
  final double min_topup;

  @JsonKey(name: 'max_topup')
  final double max_topup;

  @JsonKey(name: 'banks')
  final List<BankInfo> banks;

  TopupInfoResponse(this.notes, this.banks, this.minAmount, this.maxAmount, this.min_topup, this.max_topup);

  factory TopupInfoResponse.fromString(String body) =>
      _$TopupInfoResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory TopupInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$TopupInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopupInfoResponseToJson(this);
}

@JsonSerializable()
class TopupHistoryResponse {
  @JsonKey(name: 'id')
  late final int serverId;

  @JsonKey(name: 'agenid')
  late final String userId;

  @JsonKey(name: 'bank')
  late final String bank;

  @JsonKey(name: 'jmldep')
  late final double amount;

  @JsonKey(name: 'mutasi')
  late final double mutasi;

  @JsonKey(name: 'tanggal')
  late final DateTime transactionDate;

  @JsonKey(name: 'tanggal_aktif')
  late final DateTime confirmedDate;

  @JsonKey(name: 'tanggal_bayar')
  late final DateTime? paidDate;

  @JsonKey(name: 'status')
  late final int status;

  @JsonKey(name: 'catatan')
  late final String notes;

  TopupHistoryResponse();

  factory TopupHistoryResponse.fromString(String body) =>
      _$TopupHistoryResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory TopupHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$TopupHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopupHistoryResponseToJson(this);
}
