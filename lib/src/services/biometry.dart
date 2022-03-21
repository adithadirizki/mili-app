import 'package:local_auth/local_auth.dart';

final LocalAuthentication localAuthentication = LocalAuthentication();

Future<bool> isBiometrySupported() {
  return localAuthentication.isDeviceSupported();
}

Future<bool> canCheckBiometrics() {
  return localAuthentication.canCheckBiometrics;
}

Future<List<BiometricType>> getType() async {
  List<BiometricType> biometricTypes =
      await localAuthentication.getAvailableBiometrics();
  return biometricTypes;
}

Future<bool> authenticateBiometric(String label) async {
  if (!await isBiometrySupported() || !await canCheckBiometrics()) {
    return false;
  }
  return await localAuthentication.authenticate(
    localizedReason: label,
    biometricOnly: false,
  );
}
