import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppAnalytic {
  AppAnalytic._();

  static Future<void> initialize() async {
    FirebaseCrashlytics.instance.setCustomKey('app_name', 'MILI V2'); // FIXME Harusnya otomatis dari package name
    FirebaseCrashlytics.instance.setCustomKey('debug', '5'); // FIXME Otomamtis dari debug code
  }

  static void setUserId(String userId) {
    FirebaseCrashlytics.instance.setCustomKey('user_id', userId);
  }

  static void setUserEmail(String email) {
    FirebaseCrashlytics.instance.setCustomKey('user_email', email);
  }

  static void testCrash() {
    FirebaseCrashlytics.instance.crash();
    // FirebaseCrashlytics.instance
    //     .log("Test crash at ${formatDate(DateTime.now())}");
  }
}
