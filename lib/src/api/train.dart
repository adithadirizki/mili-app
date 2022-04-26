import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'train.g.dart';

@JsonSerializable()
class TrainStationResponse {
  @JsonKey(name: 'id')
  final int serverId;

  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'name')
  final String stationName;

  @JsonKey(name: 'fullname')
  final String stationFullname;

  @JsonKey(name: 'city')
  final String city;

  @JsonKey(name: 'updated_at')
  late final DateTime updatedDate;

  TrainStationResponse(this.serverId, this.code, this.stationName,
      this.stationFullname, this.city, this.updatedDate);

  factory TrainStationResponse.fromString(String body) =>
      _$TrainStationResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory TrainStationResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainStationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainStationResponseToJson(this);
}
