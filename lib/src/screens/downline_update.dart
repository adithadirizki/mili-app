import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/downline.dart';
import 'package:miliv2/src/api/profile.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/services/storage.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

import '../theme.dart';

class DownlineUpdateScreen extends StatefulWidget {
  final DownlineResponse downline;

  const DownlineUpdateScreen({
    Key? key,
    required this.downline,
  }) : super(key: key);

  @override
  _DownlineUpdateScreenState createState() => _DownlineUpdateScreenState();
}

class _DownlineUpdateScreenState extends State<DownlineUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _markupController = TextEditingController();
  final _outletTypeController = TextEditingController();

  double markup = 0.0;

  bool _valid = true;
  late AppAuth authState; // get auth state
  bool isLoading = false;
  ProfileConfig profileConfig = ProfileConfig(0, 100);

  @override
  void initState() {
    super.initState();

    var userProfile = AppStorage.getUserProfile(); // Cache
    if (userProfile.isNotEmpty) {
      Map<String, dynamic> userProfileMap = json.decode(userProfile) as Map<String, dynamic>;
      profileConfig = ProfileConfig.fromJson(userProfileMap['config'] as Map<String, dynamic>);
    }

    _nameController.text = widget.downline.name;
    _phoneController.text = widget.downline.phoneNumber;
    _emailController.text = widget.downline.email;
    _markupController.text = formatNumber(widget.downline.markup);
    _addressController.text = widget.downline.address ?? '';
    _outletTypeController.text = widget.downline.outletType ?? '';
  }

  FutureOr<void> _handleError(dynamic e) {
    isLoading = false;
    setState(() {});
    snackBarDialog(context, e.toString());
  }

  void onMarkupChange(String value) {
    var number = parseDouble(value);
    if (number > profileConfig.maxMarkup) {
      number = profileConfig.maxMarkup;
    } else if (number < profileConfig.minMarkup) {
      number = profileConfig.minMarkup;
    }
    //
    value = formatNumber(number);
    _markupController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(
        offset: value.length,
      ),
    );
    setState(() {
      markup = number;
    });
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      isLoading = true;
      setState(() {});
      Api.updateDownline(widget.downline.userId, markup: markup)
          .then((response) {
        Map<String, dynamic>? bodyMap =
            json.decode(response.body) as Map<String, dynamic>?;
        debugPrint("Response >> ${bodyMap}");
        var status = response.statusCode;
        if (status == 200) {}
        snackBarDialog(context, 'Downline berhasil diubah');
        popScreenWithCallback<bool>(context, true);
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
              Container(
                // constraints: BoxConstraints.loose(const Size(300, 300)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    TextFormField(
                      readOnly: true,
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputName,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Nama';
                        }
                        return null;
                      },
                    ),
                    // Phone
                    TextFormField(
                      readOnly: true,
                      controller: _phoneController,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputPhone,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Nomor Telepon';
                        }
                        return null;
                      },
                    ),
                    // Email
                    TextFormField(
                      readOnly: true,
                      controller: _emailController,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputEmail,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Email';
                        }
                        return null;
                      },
                    ),
                    // Markup
                    TextFormField(
                      controller: _markupController,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputMarkup,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Markup';
                        } else if (parseDouble(value) < profileConfig.minMarkup) {
                          return 'Minimal markup ' + profileConfig.minMarkup.toInt().toString();
                        } else if (parseDouble(value) > profileConfig.maxMarkup) {
                          return 'Maximal markup ' + profileConfig.maxMarkup.toInt().toString();
                        }
                        return null;
                      },
                      onChanged: onMarkupChange,
                    ),
                    // Jenis Toko
                    TextFormField(
                      readOnly: true,
                      controller: _outletTypeController,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputMerchantType,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Email';
                        }
                        return null;
                      },
                    ),
                    // Address
                    TextFormField(
                      readOnly: true,
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      maxLength: 200,
                      maxLines: 2,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputAddress,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Alamat';
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
        title: 'Update Markup',
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
