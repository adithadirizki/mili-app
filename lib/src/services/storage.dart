import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const String _tokenKey = "_token";
  static const String _deviceIdKey = "_deviceId";
  static const String _signedInKey = "_signedIn";
  static const String _verifiedKey = "_vefified";
  static const String _usernameKey = "_username";
  static const String printerAddressKey = "_printerAddress";

  // Private
  static const String _pinEnable = "_pinEnable";
  static const String _userPIN = "_userPIN";
  static const String _biometricEnable = "_biometricEnable";
  static const String _printerAddress = "_printerAddress";

  static late final SharedPreferences _engine;

  AppStorage._();

  static Future<void> initialize() async {
    _engine = await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get engine async {
    return _engine;
  }

  static void setAuthenticated(bool? value) {
    if (null != value) {
      _engine.setBool(_signedInKey, value);
    } else {
      _engine.remove(_signedInKey);
    }
  }

  static bool getAuthenticated() {
    bool? value = _engine.getBool(_signedInKey);
    return value ?? false;
  }

  static void setVerified(bool? value) {
    if (null != value) {
      _engine.setBool(_verifiedKey, value);
    } else {
      _engine.remove(_verifiedKey);
    }
  }

  static bool getVerified() {
    bool? value = _engine.getBool(_verifiedKey);
    return value ?? false;
  }

  static void setToken(String? value) {
    if (null != value) {
      _engine.setString(_tokenKey, value);
    } else {
      _engine.remove(_tokenKey);
    }
  }

  static String getToken() {
    String? value = _engine.getString(_tokenKey);
    return value ?? '';
  }

  static void setUsername(String? value) {
    if (null != value) {
      _engine.setString(_usernameKey, value);
    } else {
      _engine.remove(_usernameKey);
    }
  }

  static String getUsername() {
    String? value = _engine.getString(_usernameKey);
    return value ?? '';
  }

  static void setDeviceId(String? value) {
    if (null != value) {
      _engine.setString(_deviceIdKey, value);
    } else {
      _engine.remove(_deviceIdKey);
    }
  }

  static String getDeviceId() {
    String? value = _engine.getString(_deviceIdKey);
    return value ?? '';
  }

  static void setPINEnable(bool value) {
    _engine.setBool(_pinEnable, value);
  }

  static bool getPINEnable() {
    bool? value = _engine.getBool(_pinEnable);
    return value ?? false;
  }

  static void setPIN(String value) {
    _engine.setString(_userPIN, value);
  }

  static String getPIN() {
    String? value = _engine.getString(_userPIN);
    return value ?? '';
  }

  static void setBiometricEnable(bool value) {
    _engine.setBool(_biometricEnable, value);
  }

  static bool getBiometricEnable() {
    bool? value = _engine.getBool(_biometricEnable);
    return value ?? false;
  }

  static void setPrinterAddress(String value) {
    _engine.setString(_printerAddress, value);
  }

  static String? getPrinterAddress() {
    _engine.getString(_printerAddress);
  }

  static void removePrinterAddress() {
    _engine.remove(_printerAddress);
  }
}
