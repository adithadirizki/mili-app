import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

Future<String> getDeviceId() async {
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await _deviceInfo.androidInfo;
    return info.androidId ?? '';
  } else if (Platform.isIOS) {
    IosDeviceInfo info = await _deviceInfo.iosInfo;
    return info.identifierForVendor ?? '';
  }
  return '';
}

Future<String> getDeviceInfo() async {
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await _deviceInfo.androidInfo;
    return [info.brand, info.model].join('|');
  } else if (Platform.isIOS) {
    IosDeviceInfo info = await _deviceInfo.iosInfo;
    return [info.utsname.machine, info.model].join('|');
  }
  return '';
}

Future<String> getPackageName() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String packageName = packageInfo.packageName;
  return packageName;
}

Future<String> getFullAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appName = packageInfo.appName;
  String packageName = packageInfo.packageName;
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  return [appName, packageName, version, buildNumber].join('|');
}

Future<String> getOSInfo() async {
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await _deviceInfo.androidInfo;
    return [
      'OS ${info.version.baseOS}',
      'Name ${info.version.codename}',
      'Version ${info.version.release}',
      'SDK ${info.version.sdkInt}',
    ].join(' | ');
  } else if (Platform.isIOS) {
    IosDeviceInfo info = await _deviceInfo.iosInfo;
    return info.model ?? '';
  }
  return '';
}

Future<String> getDeviceModel() async {
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await _deviceInfo.androidInfo;
    return '${info.brand?.toUpperCase()} ${info.model}';
  } else if (Platform.isIOS) {
    IosDeviceInfo info = await _deviceInfo.iosInfo;
    return '${info.utsname.machine} ${info.model}';
  }
  return '';
}

Future<String> getScreenRes() async {
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await _deviceInfo.androidInfo;
    return '${info.display}';
  } else if (Platform.isIOS) {
    IosDeviceInfo info = await _deviceInfo.iosInfo;
    return '';
  }
  return '';
}

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<String> getBuildNumber() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber;
}

Future<String> getOSName() async {
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await _deviceInfo.androidInfo;
    return '${info.version.codename} ${info.version.release ?? '-'} (${info.version.sdkInt})';
  } else if (Platform.isIOS) {
    IosDeviceInfo info = await _deviceInfo.iosInfo;
    return info.model ?? '';
  }
  return '';
}
