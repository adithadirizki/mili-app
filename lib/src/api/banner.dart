import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:miliv2/src/config/config.dart';

part 'banner.g.dart';

@JsonSerializable()
class BannerResponse {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'url')
  final String url;

  String getImageUrl() {
    return AppConfig.baseUrl + '/' + url;
  }

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'banner_link')
  final String? bannerLink;

  @JsonKey(name: 'weight')
  final int weight;

  BannerResponse(this.id, this.url, this.title, this.description,
      this.bannerLink, this.weight);

  factory BannerResponse.fromString(String body) =>
      _$BannerResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory BannerResponse.fromJson(Map<String, dynamic> json) =>
      _$BannerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BannerResponseToJson(this);
}
