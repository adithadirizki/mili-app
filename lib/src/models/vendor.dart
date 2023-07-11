import 'dart:convert';

import 'package:miliv2/src/api/product.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:objectbox/objectbox.dart';

@Entity(uid: 4622272897929992148)
class Vendor {
  int id;
  int serverId;
  String name;
  String description;
  String title;
  String imageUrl;
  String group;
  String inquiryCode;
  String paymentCode;
  String productCode;
  String? config;
  List<String>? productGroupNameList;
  int productType;
  int? weight;
  @Property(uid: 4045970178139976307, type: PropertyType.date)
  DateTime updatedAt;

  Vendor({
    this.id = 0,
    required this.serverId,
    required this.name,
    this.description = '',
    required this.title,
    required this.imageUrl,
    required this.group,
    this.inquiryCode = '',
    this.paymentCode = '',
    this.productCode = '',
    this.config,
    this.productGroupNameList,
    required this.productType,
    this.weight,
    required this.updatedAt,
  });

  String getImageUrl() {
    if (imageUrl.isNotEmpty) {
      return AppConfig.baseUrl + '/' + imageUrl;
    }
    return '';
  }

  factory Vendor.fromResponse(VendorResponse response) => Vendor(
        // id: ,
        serverId: response.serverId,
        name: response.name,
        description: response.description ?? '',
        title: response.title ?? '',
        imageUrl: response.imageUrl,
        group: response.group,
        inquiryCode: response.inquiryCode ?? '',
        paymentCode: response.paymentCode ?? '',
        productCode: response.productCode ?? '',
        config: json.encode(response.config),
        productGroupNameList: response.productGroupNameList,
        productType: response.productType,
        weight: response.weight,
        updatedAt: response.updatedAt,
      );

  VendorConfigResponse? get configMap =>
      config == null ? null : VendorConfigResponse.fromString(config!);
}
