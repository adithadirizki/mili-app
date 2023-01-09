import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:miliv2/src/utils/parsing.dart';

part 'program.g.dart';

@JsonSerializable()
class ProgramResponse {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'program_code')
  final String code;

  @JsonKey(name: 'program_name')
  final String title;

  @JsonKey(name: 'program_active', fromJson: intToBool, toJson: boolToInt)
  final bool isActive;

  @JsonKey(name: 'is_opened')
  final bool isOpened;

  @JsonKey(name: 'start_at')
  final String startAt;

  @JsonKey(name: 'end_at')
  final String endAt;

  ProgramResponse(this.id, this.code, this.title, this.isActive, this.isOpened, this.startAt, this.endAt);

  factory ProgramResponse.fromString(String body) =>
      _$ProgramResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory ProgramResponse.fromJson(Map<String, dynamic> json) =>
      _$ProgramResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProgramResponseToJson(this);
}
