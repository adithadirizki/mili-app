// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:miliv2/src/consts/consts.dart';
import 'package:miliv2/src/routing.dart';
import 'package:miliv2/src/screens/forgot_password.dart';
import 'package:miliv2/src/screens/sign_up.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/images.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/button.dart';

import '../theme.dart';

class Credentials {
  final String username;
  final String password;

  Credentials(this.username, this.password);
}

class SignInScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignIn;

  const SignInScreen({
    required this.onSignIn,
    Key? key,
  }) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscure = true;

  AppAuth authState = AppAuth();
  StreamSubscription<Map>? streamSubscription;

  @override
  void initState() {
    super.initState();
    listenDynamicLinks();
  }

  void listenDynamicLinks() {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) {
      // only when not signed in
      if (data['key_page'] == pageRegister) {
        pushScreen(
            context,
            (_) => SignUpScreen(
                onVerified: (authState.onSignUp),
                onBack: () {},
                referralCode: data['referral_code']?.toString()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // width: 414, // harus dinamis by screen
        // height: 896, // harus dinamis by screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment(-5, -1),
              end: Alignment(0, 2),
              colors: [
                Color.fromRGBO(0, 255, 193, 1),
                Color.fromRGBO(0, 10, 255, 0.9938945174217224)
              ]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(flex: 1),
            const SizedBox(height: 40),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Image(
                  image: AppImages.logoWhite,
                  height: 77,
                  fit: BoxFit.fill,
                ),
              ],
            ),
            const Spacer(flex: 1),
            Container(
              // constraints: BoxConstraints.loose(const Size(300, 300)),
              padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    maxLength: 100,
                    decoration: generateInputDecoration(
                      hint: '08xxxxxxxx',
                      label: AppLabel.userId,
                      color: Colors.white,
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.text,
                    decoration: generateInputDecoration(
                      label: AppLabel.password,
                      color: Colors.white,
                      suffixIcon: IconButton(
                          color: Colors.white,
                          icon: Icon(_isObscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          }),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: TextButton(
                      onPressed: () async {
                        // RouteStateScope.of(context).go('/forgot');
                        Navigator.push(context, MaterialPageRoute<void>(
                          builder: (context) {
                            return const ForgotPasswordScreen();
                          },
                        ));
                      },
                      child: Text(
                        AppLabel.forgotPassword,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppColors.white1,
                              letterSpacing: 0,
                            ),
                        // style: TextStyle(
                        //   color: Color.fromRGBO(255, 255, 255, 1),
                        //   fontFamily: 'Montserrat',
                        //   // fontSize: 9,
                        //   letterSpacing:
                        //       0 /*percentages not used in flutter. defaulting to zero*/,
                        //   // fontWeight: FontWeight.normal,
                        //   // height: 1
                        // ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: AppButton(AppLabel.login, () {
                      widget.onSignIn(Credentials(
                        _usernameController.value.text,
                        _passwordController.value.text,
                      ));
                    }),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: AppButton(AppLabel.register, () {
                      RouteStateScope.of(context).go('/signup');
                    }),
                  ),
                  // )
                ],
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
