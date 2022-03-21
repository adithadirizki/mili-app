import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:miliv2/src/api/product.dart';

part 'purchase.g.dart';

@JsonSerializable()
class InquiryResponse {
  @JsonKey(name: 'amount')
  final double amount;

  @JsonKey(name: 'data')
  final String inquiryDetail;

  InquiryResponse(this.amount, this.inquiryDetail);

  factory InquiryResponse.fromString(String body) =>
      _$InquiryResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory InquiryResponse.fromJson(Map<String, dynamic> json) =>
      _$InquiryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryResponseToJson(this);
}

@JsonSerializable()
class TransferInfoResponse {
  @JsonKey(name: 'notes')
  final String notes;

  @JsonKey(name: 'min_amount')
  final double minAmount;

  @JsonKey(name: 'max_amount')
  final double maxAmount;

  TransferInfoResponse(this.notes, this.minAmount, this.maxAmount);

  factory TransferInfoResponse.fromString(String body) =>
      _$TransferInfoResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory TransferInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransferInfoResponseToJson(this);
}

@JsonSerializable()
class TransferInquiryResponse {
  @JsonKey(name: 'target')
  final Map<String, dynamic> target;

  @JsonKey(name: 'data')
  final String inquiryDetail;

  TransferInquiryResponse(this.target, this.inquiryDetail);

  factory TransferInquiryResponse.fromString(String body) =>
      _$TransferInquiryResponseFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory TransferInquiryResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferInquiryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransferInquiryResponseToJson(this);
}

@JsonSerializable()
class TransferResponse {
  @JsonKey(name: 'target')
  final Map<String, dynamic> target;

  @JsonKey(name: 'data')
  final String inquiryDetail;

  TransferResponse(this.target, this.inquiryDetail);

  factory TransferResponse.fromString(String body) =>
      _$TransferResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory TransferResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransferResponseToJson(this);
}

@JsonSerializable()
class PurchaseHistoryResponse {
  @JsonKey(name: 'id')
  late final int serverId;

  @JsonKey(name: 'agenid')
  late String userId;

  @JsonKey(name: 'vtype')
  late final String productCode;

  @JsonKey(name: 'voucher_name')
  late final String productName;

  @JsonKey(name: 'voucher_operator')
  late final String groupName;

  @JsonKey(name: 'tujuan')
  late final String destination;

  @JsonKey(name: 'tanggal')
  late final DateTime transactionDate;

  @JsonKey(name: 'status')
  late final String status;

  @JsonKey(name: 'harga')
  late final double price;

  @JsonKey(name: 'voucher_config')
  late final VendorResponse? productConfig;

  @JsonKey(name: 'voucher_detail')
  late final String? productDetail;

  @JsonKey(name: 'struct')
  late final String? purchaseStruct;

  PurchaseHistoryResponse();

  factory PurchaseHistoryResponse.fromString(String body) =>
      _$PurchaseHistoryResponseFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory PurchaseHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseHistoryResponseToJson(this);
}

@JsonSerializable()
class PurchaseHistoryDetailResponse {
  @JsonKey(name: 'config')
  final List<Map<String, dynamic>>? config;

  @JsonKey(name: 'data')
  final String invoice;

  PurchaseHistoryDetailResponse(this.invoice, this.config);

  factory PurchaseHistoryDetailResponse.fromString(String body) =>
      _$PurchaseHistoryDetailResponseFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory PurchaseHistoryDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseHistoryDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseHistoryDetailResponseToJson(this);
}
