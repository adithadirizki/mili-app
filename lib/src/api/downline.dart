import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:miliv2/src/config/config.dart';

part 'downline.g.dart';

@JsonSerializable()
class DownlineResponse {
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

  @JsonKey(name: 'last_active')
  late final DateTime lastActivityDate;

  @JsonKey(name: 'balance')
  late final double balance;

  @JsonKey(name: 'balance_credit')
  late final double balanceCredit;

  @JsonKey(name: 'level')
  late final int level;

  @JsonKey(name: 'up')
  late final double markup;

  @JsonKey(name: 'phone_verified')
  late final bool phoneVerified;

  @JsonKey(name: 'email_verified')
  late final bool emailVerified;

  @JsonKey(name: 'premium_active')
  late final bool premium;

  @JsonKey(name: 'status')
  late final bool status;

  @JsonKey(name: 'address')
  late final String? address;

  DownlineResponse();

  factory DownlineResponse.fromString(String body) =>
      _$DownlineResponseFromJson(json.decode(body) as Map<String, dynamic>);

  factory DownlineResponse.fromJson(Map<String, dynamic> json) =>
      _$DownlineResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DownlineResponseToJson(this);

  String? getPhotoUrl() {
    return photo == null ? null : AppConfig.baseUrl + '/' + photo!;
  }
}
