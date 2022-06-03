import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/login.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

import '../theme.dart';

class OTPVerified {
  final bool verified;
  final String token;

  OTPVerified(this.verified, this.token);
}

class OTPVerificationScreen extends StatefulWidget {
  final ValueChanged<OTPVerified> onVerified;
  final Function onBack;

  const OTPVerificationScreen({
    required this.onVerified,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  int _timeout = 0;
  Timer? _timer;
  final _usernameController = TextEditingController();
  bool _valid = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), openPopup);
    });
  }

  void openPopup() {
    bottomSheetDialog<void>(
      context: context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          OutlinedButton(
            child: const Text('Whatsapp'),
            onPressed: () {
              requestOTP(OTPType.whatsapp);
            },
            style: outlineButtonStyle,
          ),
          const SizedBox(height: 5),
          OutlinedButton(
            child: const Text('SMS'),
            onPressed: () {
              requestOTP(OTPType.sms);
            },
            style: outlineButtonStyle,
          ),
          const SizedBox(height: 5),
          OutlinedButton(
            child: const Text('E-Mail'),
            onPressed: () {
              requestOTP(OTPType.email);
            },
            style: outlineButtonStyle,
          ),
        ],
      ),
    );
  }

  FutureOr<void> _handleError(Object e) {
    simpleSnackBarDialog(context, e.toString());
  }

  void beginTimer() {
    setState(() {
      _timeout = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeout = _timeout - 1;

        if (_timeout <= 0) {
          timer.cancel();
        }
      });
    });
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  void requestOTP(OTPType type) {
    stopTimer();
    Api.requestOTP(type).then((response) {
      Navigator.pop(context);
      simpleSnackBarDialog(context, 'OTP Terkirim');
      beginTimer();
    }).catchError(_handleError);
  }

  void verify() {
    String otp = _usernameController.value.text;

    if (otp.isEmpty) {
      setState(() {
        _valid = false;
      });
      return;
    }

    setState(() {
      _valid = true;
    });

    debugPrint("Verifikasi >> $otp");

    Api.verifyOTP(otp).then((response) {
      debugPrint("OTP Response >> ${response.body}");

      Map<String, dynamic>? bodyMap =
          json.decode(response.body) as Map<String, dynamic>?;
      var loginResp = AuthResponse.fromJson(bodyMap!);

      widget.onVerified(OTPVerified(true, loginResp.token));
    }).catchError(_handleError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar2(
        title: AppLabel.otpTitle,
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            AppLabel.otpHeader,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromRGBO(1, 132, 225, 1),
              // fontFamily: 'Montserrat',
              fontSize: 24,
              letterSpacing:
                  0 /*percentages not used in flutter. defaulting to zero*/,
              fontWeight: FontWeight.normal,
              height: 1,
            ),
          ),
          Container(
            // constraints: BoxConstraints.loose(const Size(300, 300)),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  maxLength: 50,
                  style: const TextStyle(color: Colors.blueAccent),
                  cursorColor: Colors.blueAccent,
                  decoration: generateInputDecoration(
                    label: AppLabel.otpInput,
                    color: Colors.blueAccent,
                    errorMsg: !_valid ? AppLabel.errorRequired : null,
                  ),
                  // style: Theme.of(context).textTheme.button,
                  // cursorColor: Colors.blueAccent,
                  // decoration: InputDecoration(
                  //   labelText: AppLabel.otpInput,
                  //   errorText: !_valid ? AppLabel.errorRequired : null,
                  //   counterText: "",
                  //   enabledBorder: const UnderlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.blueAccent),
                  //   ),
                  //   focusedBorder: const UnderlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.blueAccent),
                  //   ),
                  //   border: const UnderlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.blueAccent),
                  //   ),
                  //   labelStyle: const TextStyle(
                  //       color: Colors.blueAccent, fontFamily: 'Montserrat'),
                  //   hintStyle: const TextStyle(
                  //       color: Colors.blueAccent, fontFamily: 'Montserrat'),
                  //   //hintText: _hintLogin,
                  // ),
                  onChanged: (value) => {
                    if (!_valid)
                      {
                        setState(() {
                          _valid = true;
                        })
                      }
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 20),
                  child: AppButton(AppLabel.otpVerify, verify),
                ),
                TextButton(
                  onPressed: _timeout == 0 ? openPopup : null,
                  child: _timeout == 0
                      ? Text('kirim kode')
                      : Text('kirim kode ($_timeout)'),
                  style: textButtonStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}
