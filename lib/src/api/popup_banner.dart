import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:miliv2/src/config/config.dart';

part 'popup_banner.g.dart';

@JsonSerializable()
class PopupBannerResponse {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'image_url')
  final String imageUrl;

  String getImageUrl() {
    return AppConfig.baseUrl + '/' + imageUrl;
  }

  @JsonKey(name: 'url')
  final String? url;

  @JsonKey(name: 'weight')
  final int weight;

  @JsonKey(name: 'schedule')
  final String schedule;

  PopupBannerResponse(
      this.id, this.imageUrl, this.url, this.weight, this.schedule);

  factory PopupBannerResponse.fromString(String body) =>
      _$PopupBannerResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory PopupBannerResponse.fromJson(Map<String, dynamic> json) =>
      _$PopupBannerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PopupBannerResponseToJson(this);
}
