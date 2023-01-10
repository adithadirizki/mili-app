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

  static void setExternalID(String agenid) {
    OneSignal.shared.sendTag('agenid', agenid);
  }

  static void setEmail(String email) {
    OneSignal.shared.sendTag('email', email);
  }

  // must start with +628
  static void setPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('08')) {
      phoneNumber = phoneNumber.replaceFirst('08', '+628');
    } else if (phoneNumber.startsWith('628')) {
      phoneNumber = phoneNumber.replaceFirst('628', '+628');
    } else if (phoneNumber.startsWith('8')) {
      phoneNumber = phoneNumber.replaceFirst('8', '+628');
    }
    OneSignal.shared.sendTag('phone_number', phoneNumber);
  }

  static void setDeviceInfo() async {
    var merk = await getDeviceInfo();
    var os = await getOSName();
    var version = await getAppVersion();
    var data = {
      'merk': merk,
      'os': os,
      'versi': version,
    };
    OneSignal.shared.sendTags(data);
  }

  static void setName(String name) {
    OneSignal.shared.sendTag('name', name);
  }

  // GUEST, PERSONAL, PREMIUM
  static void setGroupName(String groupName) {
    OneSignal.shared.sendTag('group', groupName);
  }
}
