import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class ProfileResponse {
  @JsonKey(name: 'agenid')
  late final String userId;

  @JsonKey(name: 'nama')
  late final String name;

  @JsonKey(name: 'hp')
  late final String phoneNumber;

  @JsonKey(name: 'email')
  late final String email;

  @JsonKey(name: 'photo')
  late final String? photo;

  @JsonKey(name: 'outlet_type')
  late final String? outletType;

  @JsonKey(name: 'referral_code')
  late final String? referralCode;

  @JsonKey(name: 'tgl_daftar')
  late final DateTime registerDate;

  @JsonKey(name: 'balance')
  late final double? balance;

  @JsonKey(name: 'balance_credit')
  late final double? balanceCredit;

  @JsonKey(name: 'level')
  late final int level;

  @JsonKey(name: 'phone_verified')
  late final bool phoneVerified;

  @JsonKey(name: 'email_verified')
  late final bool? emailVerified;

  @JsonKey(name: 'premium_active')
  late final bool premium;

  @JsonKey(name: 'status')
  late final bool status;

  @JsonKey(name: 'address')
  late final String? address;

  @JsonKey(name: 'markup')
  late final double? markup;

  @JsonKey(name: 'group')
  late final String groupName;

  ProfileResponse();

  factory ProfileResponse.fromString(String body) =>
      _$ProfileResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}

@JsonSerializable()
class ProfileConfig {
  @JsonKey(name: 'min_markup')
  final double minMarkup;

  @JsonKey(name: 'max_markup')
  final double maxMarkup;

  ProfileConfig(this.minMarkup, this.maxMarkup);

  factory ProfileConfig.fromString(String body) =>
      _$ProfileConfigFromJson(json.decode(body) as Map<String, dynamic>);

  factory ProfileConfig.fromJson(Map<String, dynamic> json) =>
      _$ProfileConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileConfigToJson(this);
}