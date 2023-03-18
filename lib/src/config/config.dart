import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static bool get devMode => kDebugMode;

  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api0.mili.co.id'; // LIVE / BETA
      // return 'http://api.mili-dev.sridata.net'; // Staging
      // return 'https://thanos.sridata.net'; // LIVE / BETA (OLD)
    }
    return 'http://api.mili-dev.sridata.net';
    // return 'http://192.168.72.91:8100/0';
  }

  static String get onesignal {
    if (kReleaseMode) {
      return 'eabd6fde-5f8b-4b01-acd8-493fc7e094e9'; // Mili Digital Payment
    }
    return '05dfef9d-1947-46c7-8d62-55798a318fa2'; // Mili Digital Payment - DEV
  }

  static String get dbName {
    if (kReleaseMode) {
      return 'miliv2.db';
    }

    return 'miliv2-dev10.db';
  }
}
