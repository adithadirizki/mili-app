import 'package:flutter/material.dart';

class MiliService {
  IconData? image;
  String? imageIcon;
  Color? color;
  String? title;
  String? routeName;
  MiliService({this.image, this.title, this.color, this.imageIcon, this.routeName});
}

class MiliPromo {
  String? title;
  String? image;
  MiliPromo({this.title, this.image});
}

class MiliSaldo {
  String? title;
  IconData? iconData;
  int? saldoValue;
  MiliSaldo({this.title, this.iconData, this.saldoValue});
}

class MiliNews{
  String? image;
  String? title;
  String? content;
  String? button;
  MiliNews({this.image,this.title,this.content,this.button});
}

class ScreenArguments {
  final String title;
  final String message;

  ScreenArguments(this.title, this.message);
}

class BalanceData{
  final int balance;
  final int balanceCredit;
  final int available_balance;
  final int hutang;
  final int point;

  BalanceData({
    required this.balance,
    required this.balanceCredit,
    required this.available_balance,
    required this.hutang,
    required this.point
  });

  // factory BalanceData.fromJson(Map<String, dynamic> json){
  //   return BalanceData(
  //       balance: json['data']['balance'] ?? 0,
  //       balanceCredit: json['data']['credit'] ?? 0,
  //       available_balance: json['data']['available_balance'] ?? 0,
  //       hutang: json['data']['hutang'] ?? 0,
  //       point: json['data']['point'] ?? 0,
  //   );
  // }
}

class BannerData{
  final int offset;
  final int limit;
  final int total;
  final List<BannerDetail> data;

  BannerData({
    required this.offset,
    required this.limit,
    required this.total,
    required this.data
  });
  // factory BannerData.fromJson(Map<String, dynamic> json){
  //   List<BannerDetail> banner = (json['data'] as List).map((i)=>BannerDetail.fromJson(i)).toList();
  //   return BannerData(
  //       offset: int.parse(json['offset'].toString()),
  //       limit: int.parse(json['limit'].toString()),
  //       total: int.parse(json['total'].toString()),
  //       data: banner
  //   );
  // }
}

class BannerDetail{
  final int id;
  final String title;
  final String description;
  final String banner_link;
  final String url;

  BannerDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.banner_link,
    required this.url
  });

  // factory BannerDetail.fromJson(Map<String, dynamic> json){
  //   return BannerDetail(
  //       id: int.parse(json['id'].toString()),
  //       title: json['title'].toString(),
  //       description: json['description'].toString(),
  //       banner_link: json['banner_link'].toString(),
  //       url: json['url'].toString(),
  //   );
  // }

}

class LoginData{
  final String token;
  final MiliUser user;
  final bool isNewDevice;
  final String format;

  LoginData({
    required this.token,
    required this.user,
    required this.isNewDevice,
    required this.format
  });

  // factory LoginData.fromJson(Map<String, dynamic> json){
  //   return LoginData(
  //       token: json['token'].toString(),
  //       user: MiliUser.fromJson(json['user']),
  //       isNewDevice: json['isNewDevice'],
  //       format: json['format']
  //   );
  // }
}

class MiliUser{
  final String hp;
  final String hp2;
  final int balance;
  final int balanceCredit;
  final String nama;
  final String agenid;
  final String kelompok;
  final bool status;
  final int level;
  final String upline;
  final String last_active;
  final String cluster;
  final String tgl_daftar;
  final String email;
  final String photo;
  final bool phone_verified;
  final String outlet_type;
  final String address;
  final String referral_code;
  final bool email_verified;
  final String group_name;
  final String group;
  final String premium_expired_at;
  final int total_transaction_this_month;
  final bool premium_active;

  MiliUser({
    required this.hp,
    required this.hp2,
    required this.balance,
    required this.balanceCredit,
    required this.nama,
    required this.agenid,
    required this.kelompok,
    required this.status,
    required this.level,
    required this.upline,
    required this.last_active,
    required this.cluster,
    required this.tgl_daftar,
    required this.email,
    required this.photo,
    required this.phone_verified,
    required this.outlet_type,
    required this.address,
    required this.referral_code,
    required this.email_verified,
    required this.group_name,
    required this.group,
    required this.premium_expired_at,
    required this.total_transaction_this_month,
    required this.premium_active});


  // factory MiliUser.fromJson(Map<String, dynamic> json){
  //   return MiliUser(
  //       hp: json['hp'],
  //       hp2: json['hp2'],
  //       balance: json['balance'],
  //       balanceCredit: json['balance_credit'],
  //       nama: json['nama'],
  //       agenid: json['agenid'],
  //       kelompok: json['kelompok'],
  //       status: json['status'],
  //       level: json['level'],
  //       upline: json['upline'],
  //       last_active: json['last_active'],
  //       cluster: json['cluster'],
  //       tgl_daftar: json['tgl_daftar'],
  //       email: json['email'],
  //       photo: json['photo'],
  //       phone_verified: json['phone_verified'],
  //       outlet_type: json['outlet_type'],
  //       address: json['address'],
  //       referral_code: json['referral_code'],
  //       email_verified: json['email_verified'],
  //       group_name: json['group_name'],
  //       group: json['group'],
  //       premium_expired_at: json['premium_expired_at'],
  //       total_transaction_this_month: json['total_transaction_this_month'],
  //       premium_active: json['premium_active']);
  // }
}