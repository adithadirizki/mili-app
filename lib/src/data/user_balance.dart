import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/profile.dart';
import 'package:miliv2/src/config/config.dart';

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

  UserBalanceState(this.balance, this.balanceCredit, this.isLoading);

  void _handleResponse(Response response) {
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

    debugPrint('Fetch UserBalanceState success ${bodyMap}');
    notifyListeners();
  }

  String? getPhotoUrl() {
    return photo == null ? null : AppConfig.baseUrl + '/' + photo!;
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
final userBalanceState = UserBalanceState(0, 0, false);

class UserBalanceScope extends InheritedNotifier<UserBalanceState> {
  const UserBalanceScope({
    required UserBalanceState notifier,
    required Widget child,
    Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  static UserBalanceState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UserBalanceScope>()!.notifier!;
}
