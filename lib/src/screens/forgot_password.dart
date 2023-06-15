import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/screens/otp_verification.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/device.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/button.dart';

import '../theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  // final ValueChanged<Credentials> onSignIn;

  const ForgotPasswordScreen({
    // required this.onSignIn,
    Key? key,
  }) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final usernameController = TextEditingController();

  bool valid = true;

  bool isLoading = false;
  String? token;
  bool isObscure = true;
  String newPassword = '';
  String newPasswordConfirmation = '';

  Future<void> onSubmitUserId() async {
    if (usernameController.value.text.isEmpty) {
      setState(() {
        valid = false;
      });
      return;
    }
    setState(() {
      valid = true;
    });

    var deviceId = await getDeviceId();

    Navigator.push(context, MaterialPageRoute<void>(
      builder: (context) {
        Api.setUsername(usernameController.value.text);
        Api.setDeviceId(deviceId);

        return OTPVerificationScreen(
          onBack: () {
            Navigator.of(context).maybePop();
          },
          onVerified: onUserVerified,
        );
      },
    ));
  }

  void onUserVerified(OTPVerified credential) {
    setState(() {
      token = credential.token;
    });
    Navigator.of(context).maybePop();
  }

  Widget form1() {
    return Container(
      // constraints: BoxConstraints.loose(const Size(300, 300)),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: usernameController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: 50,
            style: const TextStyle(color: AppColors.main3),
            cursorColor: AppColors.main3,
            decoration: generateInputDecoration(
              label: AppLabel.userId,
              color: AppColors.main3,
              errorMsg: !valid ? AppLabel.errorRequired : null,
            ),
            onChanged: (value) => {
              if (!valid)
                {
                  setState(() {
                    valid = true;
                  })
                }
            },
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10, top: 20),
            child: AppButton(
              AppLabel.forgotPasswordRequestOTP,
              onSubmitUserId,
            ),
          ),
        ],
      ),
    );
  }

  void onCompleted(Response res) {
    debugPrint('completed reset ${res.body}');
    Navigator.of(context).maybePop();
  }

  FutureOr<Null> _handleError(Object e) {
    simpleSnackBarDialog(context, e.toString());
    setState(() {
      isLoading = false;
    });
  }

  Future<void> onSubmitResetPassword() async {
    setState(() {
      isLoading = true;
    });
    Api.resetPassword(newPassword, newPasswordConfirmation, token!)
        .then(onCompleted)
        .catchError(_handleError);
  }

  Widget form2() {
    return Container(
      // constraints: BoxConstraints.loose(const Size(300, 300)),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            maxLength: 50,
            cursorColor: AppColors.main3,
            obscureText: isObscure,
            decoration: generateInputDecoration(
              color: AppColors.main3,
              label: 'Password Baru',
              hint: '',
              suffixIcon: IconButton(
                color: AppColors.main3,
                icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
              ),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onChanged: (newValue) {
              newPassword = newValue;
            },
          ),
          TextFormField(
            maxLength: 50,
            cursorColor: AppColors.main3,
            obscureText: isObscure,
            decoration: generateInputDecoration(
              color: AppColors.main3,
              label: 'Konfirmasi Password',
              hint: '',
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onChanged: (newValue) {
              newPasswordConfirmation = newValue;
            },
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10, top: 20),
            child: AppButton(
              'Kirim',
              onSubmitResetPassword,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          AppLabel.forgotPasswordTitle,
          style: TextStyle(color: AppColors.main2),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.main2,
          ),
          tooltip: AppLabel.backNavigation,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            AppLabel.forgotPasswordHeader,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.main2,
              fontFamily: 'Montserrat',
              fontSize: 24,
              letterSpacing:
                  0 /*percentages not used in flutter. defaulting to zero*/,
              fontWeight: FontWeight.normal,
              height: 1,
            ),
          ),
          token == null ? form1() : form2()
        ],
      ),
    );
  }
}
