import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:miliv2/src/config/config.dart';

part 'promo.g.dart';

@JsonSerializable()
class PromoResponse {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'url')
  final String url;

  String getImageUrl() {
    return AppConfig.baseUrl + '/' + url;
  }

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'link')
  final String? link;

  @JsonKey(name: 'weight')
  final int weight;

  @JsonKey(name: 'start_at')
  final DateTime startDate;

  @JsonKey(name: 'end_at')
  final DateTime endDate;

  @JsonKey(name: 'targets')
  final List<String> targets;

  PromoResponse(this.id, this.url, this.title, this.description, this.link,
      this.weight, this.startDate, this.endDate, this.targets);

  factory PromoResponse.fromString(String body) =>
      _$PromoResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory PromoResponse.fromJson(Map<String, dynamic> json) =>
      _$PromoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PromoResponseToJson(this);
}
