import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'program.g.dart';

@JsonSerializable()
class ProgramResponse {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'url')
  final String url;

  @JsonKey(name: 'link')
  final String? link;

  @JsonKey(name: 'start_at')
  final DateTime startDate;

  @JsonKey(name: 'end_at')
  final DateTime endDate;

  ProgramResponse(this.id, this.code, this.title, this.description, this.url, this.link,
      this.startDate, this.endDate);

  factory ProgramResponse.fromString(String body) =>
      _$ProgramResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory ProgramResponse.fromJson(Map<String, dynamic> json) =>
      _$ProgramResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProgramResponseToJson(this);
}
