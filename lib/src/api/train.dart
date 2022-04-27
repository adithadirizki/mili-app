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

@JsonSerializable()
class TrainScheduleDetailResponse {
  @JsonKey(name: 'class')
  final String classCode;

  @JsonKey(name: 'class_name')
  final String className;

  @JsonKey(name: 'sub_class')
  final String subClass;

  @JsonKey(name: 'adult_price')
  final double adultPrice;

  @JsonKey(name: 'child_price')
  final double childPrice;

  @JsonKey(name: 'available_seat')
  final int availableSeat;

  TrainScheduleDetailResponse(this.classCode, this.className, this.subClass,
      this.adultPrice, this.childPrice, this.availableSeat);

  factory TrainScheduleDetailResponse.fromString(String body) =>
      _$TrainScheduleDetailResponseFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory TrainScheduleDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainScheduleDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainScheduleDetailResponseToJson(this);
}

@JsonSerializable()
class TrainScheduleResponse {
  @JsonKey(name: 'train_no')
  final String trainNo;

  @JsonKey(name: 'train_name')
  final String trainName;

  @JsonKey(name: 'depart_datetime')
  final DateTime departureDatetime;

  @JsonKey(name: 'arrival_datetime')
  final DateTime arrivalDatetime;

  @JsonKey(name: 'detail')
  final TrainScheduleDetailResponse detail;

  TrainScheduleResponse(this.trainNo, this.trainName, this.departureDatetime,
      this.arrivalDatetime, this.detail);

  factory TrainScheduleResponse.fromString(String body) =>
      _$TrainScheduleResponseFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory TrainScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainScheduleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainScheduleResponseToJson(this);
}

abstract class TrainPassengerData {}

@JsonSerializable()
class TrainPassengerAdultData implements TrainPassengerData {
  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'id_number')
  String? idNumber;

  @JsonKey(name: 'phone_number')
  String? phoneNumber;

  TrainPassengerAdultData({this.name, this.idNumber, this.phoneNumber});

  factory TrainPassengerAdultData.fromString(String body) =>
      _$TrainPassengerAdultDataFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory TrainPassengerAdultData.fromJson(Map<String, dynamic> json) =>
      _$TrainPassengerAdultDataFromJson(json);

  Map<String, dynamic> toJson() => _$TrainPassengerAdultDataToJson(this);
}

@JsonSerializable()
class TrainPassengerChildData implements TrainPassengerData {
  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'id_number')
  String? idNumber;

  TrainPassengerChildData({this.name, this.idNumber});

  factory TrainPassengerChildData.fromString(String body) =>
      _$TrainPassengerChildDataFromJson(
          json.decode(body) as Map<String, dynamic>);

  factory TrainPassengerChildData.fromJson(Map<String, dynamic> json) =>
      _$TrainPassengerChildDataFromJson(json);

  Map<String, dynamic> toJson() => _$TrainPassengerChildDataToJson(this);
}
