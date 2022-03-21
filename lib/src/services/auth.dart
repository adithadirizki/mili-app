// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/login.dart';
import 'package:miliv2/src/services/storage.dart';

/// App State
/// A mock authentication service
class AppAuth extends ChangeNotifier {
  String _username = "";
  String _deviceId = "";
  bool _signedIn = false;
  bool _verified = false;

  String get deviceId => _deviceId;
  String get username => _username;
  bool get signedIn => _signedIn;
  bool get verified => _verified;

  AppAuth() {
    init();
  }

  Future<void> init() async {
    var engine = await AppStorage.engine;
    var signedIn = AppStorage.getAuthenticated();
    var verified = AppStorage.getVerified();
    var username = AppStorage.getUsername();
    var deviceId = AppStorage.getDeviceId();
    var token = AppStorage.getToken();

    debugPrint('Init Auth $signedIn $deviceId $username $token');

    if (signedIn != null &&
        signedIn &&
        token != null &&
        deviceId != null &&
        username != null &&
        verified != null) {
      _signedIn = signedIn;
      _verified = verified;
      _username = username;
      _deviceId = deviceId;

      Api.setToken(token);
      Api.setUsername(username);
      Api.setDeviceId(deviceId);
      // FIXME : callback when we got UnauthorisedException
      // Api.addErrorCallback((e) {
      //   if (e is UnauthorisedException) {
      //     signOut();
      //   }
      // });

      notifyListeners();
    }
  }

  Future<void> setAuth(bool signedIn, bool verified, String username,
      String deviceId, String token) async {
    var engine = await AppStorage.engine;

    _signedIn = signedIn;
    _verified = verified;
    _username = username;
    _deviceId = deviceId;

    // Store credential
    AppStorage.setAuthenticated(_signedIn);
    AppStorage.setVerified(_verified);
    AppStorage.setUsername(_username);
    AppStorage.setDeviceId(_deviceId);
    AppStorage.setToken(token);

    Api.setToken(token);
    Api.setUsername(_username);
    Api.setDeviceId(_deviceId);

    notifyListeners();
  }

  Future<void> setVerified(bool verified, String token) async {
    var engine = await AppStorage.engine;
    _verified = verified;

    AppStorage.setVerified(_verified);
    AppStorage.setToken(token);
    Api.setToken(token);

    notifyListeners();
  }

  Future<void> signOut() async {
    var engine = await AppStorage.engine;

    // Remove key
    AppStorage.setAuthenticated(null);
    AppStorage.setVerified(null);
    AppStorage.setUsername(null);
    AppStorage.setDeviceId(null);
    AppStorage.setToken(null);

    _signedIn = false;
    _verified = false;
    _username = '';
    _deviceId = '';

    notifyListeners();
  }

  Future<bool> signIn(String username, String password, String deviceId) async {
    var response = await Api.signIn(username, password, deviceId);
    var engine = await AppStorage.engine;

    if (response.statusCode != 200) {
      Map<String, dynamic>? bodyMap =
          json.decode(response.body) as Map<String, dynamic>?;
      var err = ErrorResponse.fromJson(bodyMap!);
      debugPrint('SignIn error ${err.errorMessage}');
      return _signedIn;
    }

    Map<String, dynamic>? bodyMap =
        json.decode(response.body) as Map<String, dynamic>?;
    var loginResp = LoginResponse.fromJson(bodyMap!);

    debugPrint('SignIn response ${loginResp.toJson()}');

    _signedIn = true;
    _verified = !loginResp.isNewDevice;
    _username = username;
    _deviceId = deviceId;

    // FIXME ganti ke service level don't use engine
    // Store credential
    AppStorage.setAuthenticated(_signedIn);
    AppStorage.setVerified(_verified);
    AppStorage.setUsername(_username);
    AppStorage.setDeviceId(_deviceId);
    AppStorage.setToken(loginResp.token);

    Api.setToken(loginResp.token);
    Api.setUsername(username);
    Api.setDeviceId(deviceId);

    notifyListeners();

    return _signedIn;
  }

  @override
  bool operator ==(Object other) =>
      other is AppAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

class AppAuthScope extends InheritedNotifier<AppAuth> {
  const AppAuthScope({
    required AppAuth notifier,
    required Widget child,
    Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  static AppAuth of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppAuthScope>()!.notifier!;
}
