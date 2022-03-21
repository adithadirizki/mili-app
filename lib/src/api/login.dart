import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'profile.dart';

part 'login.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'token')
  final String token;

  @JsonKey(name: 'format')
  final String format;

  @JsonKey(name: 'isNewDevice')
  final bool isNewDevice;

  @JsonKey(name: 'user')
  final ProfileResponse user;

  LoginResponse(this.token, this.format, this.isNewDevice, this.user);

  factory LoginResponse.fromString(String body) =>
      _$LoginResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'token')
  final String token;

  @JsonKey(name: 'user')
  final ProfileResponse user;

  AuthResponse(this.token, this.user);

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
