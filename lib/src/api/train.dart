import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:miliv2/src/utils/parsing.dart';

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

  String estimationTime() {
    final timeDiff = arrivalDatetime.difference(departureDatetime);
    final hours = (timeDiff.inMinutes / 60).floor();
    final minutes = timeDiff.inMinutes % 60;
    return '$hours Jam $minutes Menit';
  }
}

@JsonSerializable()
class TrainPassenger {
  @JsonKey(name: 'id')
  final int passengerId;

  @JsonKey(name: 'wagon_code', fromJson: intToStr)
  String wagonCode;

  @JsonKey(name: 'wagon_no', fromJson: intToStr)
  String wagonNo;

  @JsonKey(name: 'row', fromJson: strToInt)
  final int row;

  @JsonKey(name: 'column', fromJson: strToInt)
  final int column;

  @JsonKey(name: 'seat_row', fromJson: strToInt)
  int seatRow;

  @JsonKey(name: 'seat_column')
  String seatColumn;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'id_number')
  final String? idNumber;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  TrainPassenger(
      this.passengerId,
      this.wagonCode,
      this.wagonNo,
      this.row,
      this.column,
      this.seatRow,
      this.seatColumn,
      this.name,
      this.idNumber,
      this.phoneNumber);

  factory TrainPassenger.fromString(String body) =>
      _$TrainPassengerFromJson(json.decode(body) as Map<String, dynamic>);

  factory TrainPassenger.fromJson(Map<String, dynamic> json) =>
      _$TrainPassengerFromJson(json);

  Map<String, dynamic> toJson() => _$TrainPassengerToJson(this);
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

@JsonSerializable()
class TrainBookingResponse {
  @JsonKey(name: 'id')
  final int bookingId;

  @JsonKey(name: 'departure')
  final String departureCode;

  @JsonKey(name: 'departure_station')
  final TrainStationResponse departure;

  @JsonKey(name: 'destination')
  final String destinationCode;

  @JsonKey(name: 'destination_station')
  final TrainStationResponse destination;

  @JsonKey(name: 'depart_date')
  final DateTime departureDate;

  @JsonKey(name: 'adult_number')
  final int adultNum;

  @JsonKey(name: 'child_number')
  final int childNum;

  @JsonKey(name: 'train_no')
  final String trainNo;

  @JsonKey(name: 'train_name')
  final String trainName;

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

  @JsonKey(name: 'total_price')
  final double totalPrice;

  @JsonKey(name: 'total_admin')
  final double totalAdmin;

  @JsonKey(name: 'total_discount')
  final double totalDiscount;

  @JsonKey(name: 'grand_total')
  final double grandTotal;

  @JsonKey(name: 'booking_code')
  final String bookingCode;

  @JsonKey(name: 'booking_number')
  final String bookingNumber;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'status_description')
  final String statusDescription;

  @JsonKey(name: 'train_depart_date')
  final DateTime departureDatetime;

  @JsonKey(name: 'train_arrival_date')
  final DateTime arrivalDatetime;

  @JsonKey(name: 'created_at')
  final DateTime createdDatetime;

  @JsonKey(name: 'expired_at')
  final DateTime expiredAt;

  @JsonKey(name: 'passengers')
  final List<TrainPassenger> passengers;

  TrainBookingResponse(
    this.bookingId,
    this.departureCode,
    this.destinationCode,
    this.departureDate,
    this.adultNum,
    this.childNum,
    this.trainNo,
    this.trainName,
    this.classCode,
    this.className,
    this.subClass,
    this.adultPrice,
    this.childPrice,
    this.totalPrice,
    this.totalAdmin,
    this.totalDiscount,
    this.grandTotal,
    this.bookingCode,
    this.bookingNumber,
    this.status,
    this.statusDescription,
    this.departureDatetime,
    this.arrivalDatetime,
    this.departure,
    this.destination,
    this.createdDatetime,
    this.expiredAt,
    this.passengers,
  );

  factory TrainBookingResponse.fromString(String body) =>
      _$TrainBookingResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory TrainBookingResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainBookingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainBookingResponseToJson(this);

  bool isOpen() => status.toUpperCase() == 'OPEN';
  bool isCompleted() => status.toUpperCase() == 'PAID';
  String estimationTime() {
    final timeDiff = arrivalDatetime.difference(departureDatetime);
    final hours = (timeDiff.inMinutes / 60).floor();
    final minutes = timeDiff.inMinutes % 60;
    return '$hours Jam $minutes Menit';
  }
}

// Rows
@JsonSerializable()
class TrainRowData {
  @JsonKey(name: 'row', fromJson: strToInt)
  final int row;

  @JsonKey(name: 'column', fromJson: strToInt)
  final int column;

  @JsonKey(name: 'seat_row', fromJson: strToInt)
  final int seatRow;

  @JsonKey(name: 'seat_column')
  final String seatColumn;

  @JsonKey(name: 'subclass')
  final String subClass;

  @JsonKey(name: 'empty')
  bool isEmpty;

  TrainRowData(this.row, this.column, this.seatRow, this.seatColumn,
      this.subClass, this.isEmpty);

  factory TrainRowData.fromString(String body) =>
      _$TrainRowDataFromJson(json.decode(body) as Map<String, dynamic>);

  factory TrainRowData.fromJson(Map<String, dynamic> json) =>
      _$TrainRowDataFromJson(json);

  Map<String, dynamic> toJson() => _$TrainRowDataToJson(this);
}

// Columns
@JsonSerializable()
class TrainColumnData {
  @JsonKey(name: 'seat_column')
  final String columnName;

  @JsonKey(name: 'rows')
  final List<TrainRowData> rows;

  TrainColumnData(this.columnName, this.rows);

  factory TrainColumnData.fromString(String body) =>
      _$TrainColumnDataFromJson(json.decode(body) as Map<String, dynamic>);

  factory TrainColumnData.fromJson(Map<String, dynamic> json) =>
      _$TrainColumnDataFromJson(json);

  Map<String, dynamic> toJson() => _$TrainColumnDataToJson(this);
}

// Gerbong
@JsonSerializable()
class TrainWagonData {
  @JsonKey(name: 'wagon_code', fromJson: intToStr)
  final String wagonCode;

  @JsonKey(name: 'wagon_no', fromJson: intToStr)
  final String wagonNo;

  @JsonKey(name: 'columns')
  final List<TrainColumnData> columns;

  TrainWagonData(this.wagonCode, this.wagonNo, this.columns);

  factory TrainWagonData.fromString(String body) =>
      _$TrainWagonDataFromJson(json.decode(body) as Map<String, dynamic>);

  factory TrainWagonData.fromJson(Map<String, dynamic> json) =>
      _$TrainWagonDataFromJson(json);

  Map<String, dynamic> toJson() => _$TrainWagonDataToJson(this);
}
