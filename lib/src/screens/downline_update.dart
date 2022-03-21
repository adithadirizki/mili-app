import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/downline.dart';
import 'package:miliv2/src/services/auth.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.downline.name;
    _phoneController.text = widget.downline.phoneNumber;
    _emailController.text = widget.downline.email;
    _markupController.text = widget.downline.markup.toString();
    _addressController.text = widget.downline.address ?? '';
    _outletTypeController.text = widget.downline.outletType ?? '';
  }

  FutureOr<void> _handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  void onMarkupChange(String value) {
    var number = parseDouble(value);
    if (number > 500) {
      number = 500;
    } else if (number < 0) {
      number = 0;
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
      Api.updateDownline(widget.downline.userId, markup: markup)
          .then((response) {
        Map<String, dynamic>? bodyMap =
            json.decode(response.body) as Map<String, dynamic>?;
        debugPrint("Response >> ${bodyMap}");
        var status = response.statusCode;
        if (status == 200) {}
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
                        color: Colors.blueAccent,
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
                        color: Colors.blueAccent,
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
                        color: Colors.blueAccent,
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
                        color: Colors.blueAccent,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Markup';
                        } else if (parseDouble(value) < 0) {
                          return 'Minimal markup 0';
                        } else if (parseDouble(value) > 500) {
                          return 'Maximal markup 500';
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
                        color: Colors.blueAccent,
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
                        color: Colors.blueAccent,
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
                      child: AppButton('Simpan', submit),
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
