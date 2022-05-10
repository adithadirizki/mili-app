import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/profile.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/services/storage.dart';

class UserBalanceState extends ChangeNotifier {
  bool isLoading = false;
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
  String groupName = 'RETAIL';

  UserBalanceState(this.balance, this.balanceCredit, this.isLoading);

  factory UserBalanceState.fromCache() {
    var body = AppStorage.getUserProfile(); // Cache
    if (body.isEmpty) {
      return UserBalanceState(0, 0, false);
    }
    try {
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
        ..groupName = profile.groupName;
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

    debugPrint('Fetch UserBalanceState success ${bodyMap}');
    notifyListeners();
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

  FutureOr<void> _handleError(Object e) {
    debugPrint('Fetch UserBalanceState error $e');
    throw e;
  }

  Future<void> fetchData() {
    isLoading = true;
    notifyListeners();
    return Api.getProfile().then(_handleResponse).catchError(_handleError);
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
