import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static bool get devMode => kDebugMode;

  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://thanos.sridata.net';
    }
    // return 'http://api.mili-dev.sridata.net';
    return 'http://192.168.20.102:8100/0';
  }

  static String get dbName {
    if (kReleaseMode) {
      return 'miliv2.db';
    }

    return 'miliv2-dev10.db';
  }
}
