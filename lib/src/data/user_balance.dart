import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/profile.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/services/onesignal.dart';
import 'package:miliv2/src/services/storage.dart';

class UserBalanceState extends ChangeNotifier {
  bool isLoading = false;
  bool walletActive = false;
  double walletBalance = 0;
  bool walletPremium = false;
  double balance = 0;
  double balanceCredit = 0;
  int level = 0;
  String userId = '';
  String name = '';
  String phoneNumber = '';
  bool phoneVerified = false;
  String email = '';
  bool emailVerified = false;
  String? photo;
  String? referralCode;
  bool premium = false;
  String? address;
  String? outletType;
  double markup = 0;
  String groupName = '';

  UserBalanceState(this.balance, this.balanceCredit, this.isLoading);

  factory UserBalanceState.fromCache() {
    var body = AppStorage.getUserProfile(); // Cache
    if (body.isEmpty) {
      return UserBalanceState(0, 0, false);
    }
    try {
      // Wallet
      var wallet = AppStorage.getWallet(); // Cache
      Map<String, dynamic> walletCache =
          json.decode(wallet) as Map<String, dynamic>;
      //
      Map<String, dynamic> bodyMap = json.decode(body) as Map<String, dynamic>;
      var profile =
          ProfileResponse.fromJson(bodyMap['data'] as Map<String, dynamic>);

      return UserBalanceState(0, 0, false)
        ..balance = (profile.balance ?? 0)
        ..balanceCredit = profile.balanceCredit ?? 0
        ..level = profile.level
        ..userId = profile.userId
        ..name = profile.name
        ..referralCode = profile.referralCode
        ..phoneNumber = profile.phoneNumber
        ..email = profile.email
        ..photo = profile.photo
        ..premium = profile.premium
        ..address = profile.address
        ..outletType = profile.outletType
        ..markup = profile.markup ?? 0
        ..groupName = profile.groupName
        // Wallet
        ..walletBalance = ((walletCache['data'] as num?)?.toDouble()) ?? 0
        ..walletActive = walletCache['status'] == 1
        ..walletPremium = walletCache['type'] != 'BASIC';
    } catch (e) {
      return UserBalanceState(0, 0, false);
    }
  }

  void _handleResponse(Response response) {
    AppStorage.seUserProfile(response.body); // Cache
    Map<String, dynamic> bodyMap =
        json.decode(response.body) as Map<String, dynamic>;
    var profile =
        ProfileResponse.fromJson(bodyMap['data'] as Map<String, dynamic>);
    balance = profile.balance ?? 0;
    balanceCredit = profile.balanceCredit ?? 0;
    level = profile.level;
    userId = profile.userId;
    name = profile.name;
    referralCode = profile.referralCode;
    phoneNumber = profile.phoneNumber;
    email = profile.email;
    photo = profile.photo;
    premium = profile.premium;
    address = profile.address;
    outletType = profile.outletType;
    markup = profile.markup ?? 0;
    groupName = profile.groupName;
    notifyListeners();

    AppOnesignal.setProfile(
        agenid: profile.userId,
        name: profile.name,
        balance: profile.balance,
        creditBalance: profile.balanceCredit,
        phoneNumber: profile.phoneNumber,
        email: profile.email,
        groupName: profile.groupName,
        registerDate: profile.registerDate
    );
  }

  String? getPhotoUrl() {
    return photo == null ? null : AppConfig.baseUrl + '/' + photo!;
  }

  bool isGuest() {
    return groupName.isEmpty || groupName == 'GUEST';
  }

  bool isAllowedPurchase() {
    return !isGuest() && phoneVerified;
  }

  Future<void> fetchData() {
    isLoading = true;
    notifyListeners();
    return Api.getProfile().then(_handleResponse);
  }

  Future<Response> fetchWallet() {
    isLoading = true;
    notifyListeners();
    return Api.walletBalance().then((response) {
      AppStorage.setWallet(response.body); // Cache
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      if (bodyMap['status'] == 1) {
        walletBalance = ((bodyMap['data'] as num?)?.toDouble()) ?? 0;
        walletActive = true;
        walletPremium = bodyMap['type'] != 'BASIC';
        notifyListeners();
      }
      return response;
    });
  }
}

// // @deprecated
// final userBalanceProvider = ChangeNotifierProvider(create: (context) {
//   return UserBalanceState(0, 0, false);
// });

// Initialized
final userBalanceState = UserBalanceState.fromCache();

class UserBalanceScope extends InheritedNotifier<UserBalanceState> {
  const UserBalanceScope({
    required UserBalanceState notifier,
    required Widget child,
    Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  static UserBalanceState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UserBalanceScope>()!.notifier!;
}
