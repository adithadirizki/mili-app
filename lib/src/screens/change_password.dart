import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

import '../theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _valid = true;
  late AppAuth authState; // get auth state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  FutureOr<void> _handleError(Object e) {
    isLoading = false;
    setState(() {});
    snackBarDialog(context, e.toString());
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      var currentPassowrd = _currentPasswordController.value.text;
      var password = _passwordController.value.text;
      var confirm = _passwordConfirmController.value.text;

      Map<String, Object> body = <String, Object>{
        'old_password': currentPassowrd,
        'new_password': password,
        'new_password_confirmation': confirm,
      };
      debugPrint("Request >> ${json.encode(body)}");
      isLoading = true;
      setState(() {});
      Api.changePassword(body).then((response) {
        Map<String, dynamic>? bodyMap =
            json.decode(response.body) as Map<String, dynamic>?;
        debugPrint("Response >> ${bodyMap}");
        var status = response.statusCode;
        if (status == 200) {
          userBalanceState.fetchData();
        }
        snackBarDialog(context, 'Password berhasil diubah');
        popScreen(context);
      }).catchError(_handleError);
    }
  }

  Widget buildForm(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),
              // const Text(
              //   'Profile',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     color: Color.fromRGBO(1, 132, 225, 1),
              //     fontFamily: 'Montserrat',
              //     fontSize: 24,
              //     letterSpacing:
              //         0 /*percentages not used in flutter. defaulting to zero*/,
              //     fontWeight: FontWeight.normal,
              //     height: 1,
              //   ),
              // ),
              Container(
                // constraints: BoxConstraints.loose(const Size(300, 300)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current Password
                    TextFormField(
                      controller: _currentPasswordController,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.main3),
                      cursorColor: AppColors.main3,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputCurrentPassword,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Password';
                        }
                        return null;
                      },
                    ),
                    // New Password
                    TextFormField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.main3),
                      cursorColor: AppColors.main3,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputNewPassword,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Password';
                        }
                        return null;
                      },
                    ),
                    // Password Confirm
                    TextFormField(
                      controller: _passwordConfirmController,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.main3),
                      cursorColor: AppColors.main3,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputConfirmPassword,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Konfirmasi Password';
                        } else if (value != _passwordController.text) {
                          return 'Password tidak sesuai';
                        }
                        return null;
                      },
                    ),
                    // Button
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 20),
                      child: AppButton(
                          'Simpan',
                          userBalanceState.isGuest() || isLoading
                              ? null
                              : submit),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar2(
        title: 'Ubah Password',
      ),
      body: buildForm(context),
    );
  }

  @override
  void dispose() {
    // stopTimer();
    super.dispose();
  }
}
