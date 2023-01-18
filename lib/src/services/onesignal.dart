import 'package:miliv2/src/utils/device.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AppOnesignal {
  static Future<void> initialize() async {
    //Remove this method to stop OneSignal Debugging
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setAppId("eabd6fde-5f8b-4b01-acd8-493fc7e094e9");

    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");

      setDeviceInfo();
    });
  }

  static void setProfile({
    required String agenid,
    required String name,
    double? balance = 0,
    double? creditBalance = 0,
    String? email,
    required String phoneNumber,
    required String groupName,
    required DateTime registerDate,
  }) {
    phoneNumber = formatPhoneNumber(phoneNumber);
    var tags = {
      'name': name,
      'balance': balance,
      'credit_balance': creditBalance,
      'group_name': groupName,
      'register_date': registerDate.millisecondsSinceEpoch,
    };
    OneSignal.shared.setExternalUserId(agenid);
    OneSignal.shared.setSMSNumber(smsNumber: phoneNumber);
    if (email != null) {
      OneSignal.shared.setEmail(email: email);
    }
    setTags(tags);
  }

  static void setDeviceInfo() async {
    var appName = await getAppName();
    var tags = {
      'app_name': appName,
    };
    setTags(tags);
  }

  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('08')) {
      phoneNumber = phoneNumber.replaceFirst('08', '+628');
    } else if (phoneNumber.startsWith('628')) {
      phoneNumber = phoneNumber.replaceFirst('628', '+628');
    } else if (phoneNumber.startsWith('8')) {
      phoneNumber = phoneNumber.replaceFirst('8', '+628');
    }
    return phoneNumber;
  }

  static void setTags(Map<String, dynamic> tags) {
    OneSignal.shared.sendTags(tags);
  }

  static Future<Map<String, dynamic>> getTags() async {
    return await OneSignal.shared.getTags();
  }
}
