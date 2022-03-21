import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class ProvinceResponse {
  @JsonKey(name: 'id')
  late final int serverId;

  @JsonKey(name: 'name')
  late final String provinceName;

  ProvinceResponse();

  factory ProvinceResponse.fromString(String body) =>
      _$ProvinceResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory ProvinceResponse.fromJson(Map<String, dynamic> json) =>
      _$ProvinceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProvinceResponseToJson(this);
}

@JsonSerializable()
class CityResponse {
  @JsonKey(name: 'id')
  late final int serverId;

  @JsonKey(name: 'name')
  late final String cityName;

  CityResponse();

  factory CityResponse.fromString(String body) =>
      _$CityResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory CityResponse.fromJson(Map<String, dynamic> json) =>
      _$CityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CityResponseToJson(this);
}

@JsonSerializable()
class DistrictResponse {
  @JsonKey(name: 'id')
  late final int serverId;

  @JsonKey(name: 'name')
  late final String districtName;

  DistrictResponse();

  factory DistrictResponse.fromString(String body) =>
      _$DistrictResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory DistrictResponse.fromJson(Map<String, dynamic> json) =>
      _$DistrictResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DistrictResponseToJson(this);
}

@JsonSerializable()
class VillageResponse {
  @JsonKey(name: 'id')
  late final int serverId;

  @JsonKey(name: 'name')
  late final String villageName;

  VillageResponse();

  factory VillageResponse.fromString(String body) =>
      _$VillageResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory VillageResponse.fromJson(Map<String, dynamic> json) =>
      _$VillageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VillageResponseToJson(this);
}
