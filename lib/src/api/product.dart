import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/utils/parsing.dart';

part 'product.g.dart';

@JsonSerializable()
class ProductResponse {
  @JsonKey(name: 'vtype')
  late String code;

  @JsonKey(name: 'ket')
  late String productName;

  @JsonKey(name: 'detail')
  late String? description;

  @JsonKey(name: 'opr')
  late String groupName;

  @JsonKey(name: 'denom')
  late double nominal;

  @JsonKey(name: 'harga1')
  late double priceLevel1;

  @JsonKey(name: 'harga2')
  late double priceLevel2;

  @JsonKey(name: 'harga3')
  late double priceLevel3;

  @JsonKey(name: 'harga4')
  late double priceLevel4;

  @JsonKey(name: 'harga5')
  late double priceLevel5;

  @JsonKey(name: 'harga6')
  late double priceLevel6;

  @JsonKey(name: 'harga7')
  late double priceLevel7;

  @JsonKey(name: 'harga8')
  late double priceLevel8;

  @JsonKey(name: 'harga9')
  late double priceLevel9;

  @JsonKey(name: 'harga10')
  late double priceLevel10;

  @JsonKey(name: 'markup')
  late double markup;

  @JsonKey(name: 'harga')
  late double price;

  @JsonKey(name: 'status')
  late int status;

  @JsonKey(name: 'jenis')
  late int voucherType; // jenis elektrik, etc

  @JsonKey(name: 'kelompok')
  late int productGroup; // kelompok pulsa data, pay etx

  @JsonKey(name: 'is_promo', fromJson: intToBool, toJson: boolToInt)
  late bool promo;

  @JsonKey(name: 'prefix')
  late String? prefix;

  @JsonKey(name: 'weight')
  late int? weight;

  @JsonKey(name: 'updated_at')
  late DateTime updatedAt;

  ProductResponse();

  factory ProductResponse.fromString(String body) =>
      _$ProductResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);
}

@JsonSerializable()
class VendorConfigResponse {
  @JsonKey(name: 'label')
  late String? label;

  @JsonKey(name: 'hint')
  late String? hint;

  @JsonKey(name: 'hide_transaction_number')
  late bool? hideNumber;

  @JsonKey(name: 'prefix_needed')
  late bool? needPrefix;

  @JsonKey(name: 'min_length')
  late int? minLength;

  @JsonKey(name: 'max_length')
  late int? maxLength;

  @JsonKey(name: 'min_denom')
  late double? minDemon;

  @JsonKey(name: 'max_denom')
  late double? maxDemon;

  @JsonKey(name: 'show_price')
  late bool? showPrice;

  VendorConfigResponse();

  factory VendorConfigResponse.fromString(String body) =>
      _$VendorConfigResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory VendorConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$VendorConfigResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VendorConfigResponseToJson(this);
}

@JsonSerializable()
class VendorResponse {
  @JsonKey(name: 'id')
  late int serverId;

  @JsonKey(name: 'name')
  late String name;

  @JsonKey(name: 'description')
  late String? description;

  @JsonKey(name: 'title')
  late String? title;

  @JsonKey(name: 'image')
  late String imageUrl;

  @JsonKey(name: 'group')
  late String group;

  @JsonKey(name: 'inquiry_code')
  late String? inquiryCode;

  @JsonKey(name: 'payment_code')
  late String? paymentCode;

  @JsonKey(name: 'product_code')
  late String? productCode;

  @JsonKey(name: 'config')
  late Map<String, dynamic>? config;

  @JsonKey(name: 'opr')
  late List<String>? productGroupNameList;

  @JsonKey(name: 'product_type')
  late int productType;

  @JsonKey(name: 'weight')
  late int? weight;

  @JsonKey(name: 'updated_at')
  late DateTime updatedAt;

  String getImageUrl() {
    return AppConfig.baseUrl + '/' + imageUrl;
  }

  VendorResponse();

  factory VendorResponse.fromString(String body) =>
      _$VendorResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory VendorResponse.fromJson(Map<String, dynamic> json) =>
      _$VendorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VendorResponseToJson(this);
}

@JsonSerializable()
class ProductCriteriaResponse {
  @JsonKey(name: 'criteria')
  late Map<String, String> criteria;

  ProductCriteriaResponse();

  factory ProductCriteriaResponse.fromString(String body) =>
      _$ProductCriteriaResponseFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory ProductCriteriaResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductCriteriaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductCriteriaResponseToJson(this);
}

@JsonSerializable()
class PriceSettingResponse {
  @JsonKey(name: 'id')
  late int serverId;

  @JsonKey(name: 'agenid')
  late String userId;

  @JsonKey(name: 'vtype')
  late String productCode;

  @JsonKey(name: 'price')
  late double price;

  @JsonKey(name: 'updated_at')
  late DateTime updatedAt;

  PriceSettingResponse();

  factory PriceSettingResponse.fromString(String body) =>
      _$PriceSettingResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory PriceSettingResponse.fromJson(Map<String, dynamic> json) =>
      _$PriceSettingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PriceSettingResponseToJson(this);
}

@JsonSerializable()
class CutoffResponse {
  @JsonKey(name: 'code')
  final String productCode;

  @JsonKey(name: 'info')
  final String? notes;

  @JsonKey(name: 'start')
  final String start;

  @JsonKey(name: 'end')
  final String end;

  CutoffResponse(this.productCode, this.notes, this.start, this.end);

  factory CutoffResponse.fromString(String body) =>
      _$CutoffResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory CutoffResponse.fromJson(Map<String, dynamic> json) =>
      _$CutoffResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CutoffResponseToJson(this);
}
