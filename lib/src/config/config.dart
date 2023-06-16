import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static bool get devMode => kDebugMode;

  static String get webUrl {
    return 'https://mymoro.id';
  }

  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://mroapi.miliapps.sridata.net';
    }
    return 'http://api.mili-dev.sridata.net';
  }

  static String get dbName {
    if (kReleaseMode) {
      return 'miliv2.db';
    }

    return 'miliv2-dev10.db';
  }
}
