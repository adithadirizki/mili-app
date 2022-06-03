import 'package:flutter/material.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/models/user_config.dart';
import 'package:miliv2/src/screens/otp_verification.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/services/biometry.dart';
import 'package:miliv2/src/services/storage.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/pin_verification.dart';

class PINSetupScreen extends StatefulWidget {
  const PINSetupScreen({Key? key}) : super(key: key);

  @override
  _PINSetupScreenState createState() => _PINSetupScreenState();
}

class _PINSetupScreenState extends State<PINSetupScreen> {
  bool pinActive = false;
  bool biometricActive = false;
  bool transactionActive = false;

  String currentPin = '';
  String newPin = '';

  final newPinState = GlobalKey<PINVerificationState>();
  final confirmPinState = GlobalKey<PINVerificationState>();
  final verifyPinState = GlobalKey<PINVerificationState>();

  bool loading = false;
  late UserConfig printConfig;

  @override
  void initState() {
    super.initState();

    currentPin = AppStorage.getPIN();
    pinActive = AppStorage.getPINEnable() && currentPin.isNotEmpty;
    biometricActive = AppStorage.getBiometricEnable();
    transactionActive = AppStorage.getTransactionPINEnable();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  Future<void> initialize() async {
    // UserConfig? prev = AppDB.userConfigDB
    //     .query(UserConfig_.name.equals('PRINTER_SETTING'))
    //     .build()
    //     .findFirst();
    // if (prev == null) {
    //   printConfig = UserConfig(
    //     serverId: 0,
    //     userId: '',
    //     name: 'PRINTER_SETTING',
    //     config: json.encode(<String, dynamic>{}),
    //     lastUpdate: DateTime.now(),
    //   );
    // } else {
    //   printConfig = prev;
    // }
  }

  Future<bool> setNewPIN(String pin) async {
    newPin = pin;
    return true;
  }

  Future<bool> validateNewPIN(String pin) async {
    return newPin == pin;
  }

  void activatePIN(BuildContext ctx) {
    popScreen(context);
    AppStorage.setPINEnable(true);
    AppStorage.setPIN(newPin);
    setState(() {
      currentPin = newPin;
      newPin = '';
      pinActive = true;
    });
  }

  void confirmNewPIN(BuildContext ctx) {
    replaceScreen(
      context,
      (_) => PINVerification.withGradientBackground(
        key: confirmPinState,
        otpLength: 4,
        secured: true,
        title: 'Aktifkan PIN',
        subTitle: 'Konfirmasi PIN',
        invalidMessage: 'PIN tidak sesuai',
        validateOtp: validateNewPIN,
        onValidateSuccess: activatePIN,
        onInvalid: (_) {
          confirmPinState.currentState!.clearOtp();
        },
        topColor: const Color.fromRGBO(0, 255, 193, 1),
        bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
        themeColor: Colors.white,
        titleColor: Colors.white,
        // icon: Image.asset(
        //   'images/phone_logo.png',
        //   fit: BoxFit.fill,
        // ),
      ),
    );
  }

  void beginActivatePIN() {
    pushScreen(
      context,
      (_) => PINVerification.withGradientBackground(
        key: newPinState,
        otpLength: 4,
        secured: true,
        title: 'Aktifkan PIN',
        subTitle: 'Masukkan PIN Baru',
        invalidMessage: 'PIN tidak sesuai',
        validateOtp: setNewPIN,
        onValidateSuccess: confirmNewPIN,
        onInvalid: (_) {},
        topColor: const Color.fromRGBO(0, 255, 193, 1),
        bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
        themeColor: Colors.white,
        titleColor: Colors.white,
        // icon: Image.asset(
        //   'images/phone_logo.png',
        //   fit: BoxFit.fill,
        // ),
      ),
    );
  }

  void beginDeactivatePIN() {
    pushScreen(
      context,
      (_) => PINVerification.withGradientBackground(
        key: verifyPinState,
        otpLength: 4,
        secured: true,
        title: 'Nonaktifkan PIN',
        subTitle: 'Masukkan PIN',
        invalidMessage: 'PIN tidak sesuai',
        validateOtp: validateCurrentPIN,
        onValidateSuccess: deactivatePIN,
        onInvalid: (_) {
          verifyPinState.currentState!.clearOtp();
        },
        topColor: const Color.fromRGBO(0, 255, 193, 1),
        bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
        themeColor: Colors.white,
        titleColor: Colors.white,
        // icon: Image.asset(
        //   'images/phone_logo.png',
        //   fit: BoxFit.fill,
        // ),
      ),
    );
  }

  void beginChangePIN() {
    void step2(BuildContext context) {
      replaceScreen(
        context,
        (_) => PINVerification.withGradientBackground(
          key: confirmPinState,
          otpLength: 4,
          secured: true,
          title: 'Ganti PIN',
          subTitle: 'Konfirmasi PIN',
          invalidMessage: 'PIN tidak sesuai',
          validateOtp: validateNewPIN,
          onValidateSuccess: activatePIN,
          onInvalid: (_) {
            confirmPinState.currentState!.clearOtp();
          },
          topColor: const Color.fromRGBO(0, 255, 193, 1),
          bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
          themeColor: Colors.white,
          titleColor: Colors.white,
          // icon: Image.asset(
          //   'images/phone_logo.png',
          //   fit: BoxFit.fill,
          // ),
        ),
      );
    }

    void step1(BuildContext context) {
      replaceScreen(
        context,
        (_) => PINVerification.withGradientBackground(
          key: newPinState,
          otpLength: 4,
          secured: true,
          title: 'Ganti PIN',
          subTitle: 'Masukkan PIN Baru',
          invalidMessage: 'PIN tidak sesuai',
          validateOtp: setNewPIN,
          onValidateSuccess: step2,
          onInvalid: (_) {},
          topColor: const Color.fromRGBO(0, 255, 193, 1),
          bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
          themeColor: Colors.white,
          titleColor: Colors.white,
          // icon: Image.asset(
          //   'images/phone_logo.png',
          //   fit: BoxFit.fill,
          // ),
        ),
      );
    }

    pushScreen(
      context,
      (_) => PINVerification.withGradientBackground(
        key: verifyPinState,
        otpLength: 4,
        secured: true,
        title: 'Ganti PIN',
        subTitle: 'Masukkan PIN',
        invalidMessage: 'PIN tidak sesuai',
        validateOtp: validateCurrentPIN,
        onValidateSuccess: step1,
        onInvalid: (_) {
          verifyPinState.currentState!.clearOtp();
        },
        topColor: const Color.fromRGBO(0, 255, 193, 1),
        bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
        themeColor: Colors.white,
        titleColor: Colors.white,
        // icon: Image.asset(
        //   'images/phone_logo.png',
        //   fit: BoxFit.fill,
        // ),
      ),
    );
  }

  Future<bool> validateCurrentPIN(String pin) async {
    return pin == currentPin;
  }

  void deactivatePIN(BuildContext ctx) {
    popScreen(context);
    AppStorage.setPINEnable(false);
    AppStorage.setPIN('');
    setState(() {
      newPin = '';
      pinActive = false;
    });
  }

  void onPinEnableChange(bool value) {
    if (!pinActive && value) {
      beginActivatePIN();
    } else {
      beginDeactivatePIN();
    }
  }

  void onBiometricChange(bool value) async {
    var success = await authenticateBiometric('Autentikasi aplikasi');
    if (success) {
      if (!biometricActive && value) {
        AppStorage.setBiometricEnable(true);
        setState(() {
          biometricActive = true;
        });
      } else {
        AppStorage.setBiometricEnable(false);
        setState(() {
          biometricActive = false;
        });
      }
    }
  }

  void onTransactionPINChange(bool value) {
    AppAuth.pinAuthentication(context, (context) {
      if (!transactionActive && value) {
        AppStorage.setTransactionPINEnable(true);
        setState(() {
          transactionActive = true;
        });
      } else {
        AppStorage.setTransactionPINEnable(false);
        setState(() {
          transactionActive = false;
        });
      }
      popScreen(context);
    });
  }

  void onPINChange() {
    if (pinActive) {
      beginChangePIN();
    }
  }

  void onForgotPIN() {
    void step2(BuildContext context) {
      replaceScreen(
        context,
        (_) => PINVerification.withGradientBackground(
          key: confirmPinState,
          otpLength: 4,
          secured: true,
          title: 'Ganti PIN',
          subTitle: 'Konfirmasi PIN',
          invalidMessage: 'PIN tidak sesuai',
          validateOtp: validateNewPIN,
          onValidateSuccess: activatePIN,
          onInvalid: (_) {
            confirmPinState.currentState!.clearOtp();
          },
          topColor: const Color.fromRGBO(0, 255, 193, 1),
          bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
          themeColor: Colors.white,
          titleColor: Colors.white,
          // icon: Image.asset(
          //   'images/phone_logo.png',
          //   fit: BoxFit.fill,
          // ),
        ),
      );
    }

    void step1(BuildContext context) {
      replaceScreen(
        context,
        (_) => PINVerification.withGradientBackground(
          key: newPinState,
          otpLength: 4,
          secured: true,
          title: 'Ganti PIN',
          subTitle: 'Masukkan PIN Baru',
          invalidMessage: 'PIN tidak sesuai',
          validateOtp: setNewPIN,
          onValidateSuccess: step2,
          onInvalid: (_) {},
          topColor: const Color.fromRGBO(0, 255, 193, 1),
          bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
          themeColor: Colors.white,
          titleColor: Colors.white,
          // icon: Image.asset(
          //   'images/phone_logo.png',
          //   fit: BoxFit.fill,
          // ),
        ),
      );
    }

    if (pinActive) {
      pushScreen(
        context,
        (_) => OTPVerificationScreen(
          onBack: () {
            Navigator.of(context).pop();
          },
          onVerified: (response) {
            debugPrint('OTP resp $response');
            step1(context);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar2(title: 'Konfigurasi PIN'),
      body: Card(
        // color: Colors.white,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Aktifkan PIN',
                  // style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Switch(
                  onChanged:
                      userBalanceState.isGuest() ? null : onPinEnableChange,
                  value: pinActive,
                  activeColor: Colors.lightBlueAccent,
                ),
              ),
              ListTile(
                title: const Text(
                  'Biometrik',
                  // style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Switch(
                  onChanged: pinActive ? onBiometricChange : null,
                  value: biometricActive,
                  activeColor: Colors.lightBlueAccent,
                ),
              ),
              ListTile(
                title: const Text(
                  'Transaksi menggunakan PIN',
                  // style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Switch(
                  onChanged: pinActive ? onTransactionPINChange : null,
                  value: transactionActive,
                  activeColor: Colors.lightBlueAccent,
                ),
              ),
              ListTile(
                title: const Text(
                  'Ganti PIN',
                  // style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: pinActive ? onPINChange : null,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 32,
                  color: pinActive ? Colors.lightBlueAccent : Colors.grey,
                ),
              ),
              ListTile(
                title: const Text(
                  'Lupa PIN',
                  // style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: pinActive ? onForgotPIN : null,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 32,
                  color: pinActive ? Colors.lightBlueAccent : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
