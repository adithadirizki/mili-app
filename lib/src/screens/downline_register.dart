import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/utils/formatter.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

import '../theme.dart';

class DownlineRegisterScreen extends StatefulWidget {
  // final VoidCallback onCompleted;

  const DownlineRegisterScreen({
    // required this.onCompleted,
    Key? key,
  }) : super(key: key);

  @override
  _DownlineRegisterScreenState createState() => _DownlineRegisterScreenState();
}

class _DownlineRegisterScreenState extends State<DownlineRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _markupController = TextEditingController();

  List<String> outletTypes = [];
  String? outletType;

  // bool _valid = true;
  late AppAuth authState; // get auth state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _markupController.text = formatNumber(0);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  FutureOr<void> _handleError(dynamic e) {
    isLoading = false;
    setState(() {});
    snackBarDialog(context, e.toString());
  }

  void initialize() {
    Api.getOutletType().then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);
      outletTypes = pagingResponse.data.map<String>((dynamic data) {
        return ((data as Map<String, dynamic>)['key']! as String);
      }).toList();
      setState(() {});
    }).catchError(_handleError);
  }

  void onMarkupChange(String value) {
    var number = parseDouble(value);
    if (number > 100) {
      number = 100;
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
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      var name = _nameController.value.text;
      var phoneNumber = _phoneController.value.text;
      var email = _emailController.value.text;
      var address = _addressController.value.text;
      var markup = _markupController.value.text;

      isLoading = true;
      setState(() {});
      Api.registerDownline(
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        outletType: outletType!,
        markup: parseDouble(markup),
        address: address,
      ).then((response) async {
        Map<String, dynamic>? bodyMap =
            json.decode(response.body) as Map<String, dynamic>?;
        debugPrint("Response >> ${bodyMap}");
        var status = response.statusCode;
        if (status == 200) {}
        snackBarDialog(context, 'Downline berhasil didaftarkan');
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
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputName,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Nama';
                        } else if (value.length < 5) {
                          return 'Nama tidak sesuai';
                        }
                        return null;
                      },
                    ),
                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      maxLength: 15,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputPhone,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Nomor Telepon';
                        } else if (value.length < 5) {
                          return 'Nomor Telepon tidak sesuai';
                        }
                        return null;
                      },
                    ),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      maxLength: 100,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputEmail,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Email';
                        } else if (value.length < 5) {
                          return 'Email tidak sesuai';
                        }
                        return null;
                      },
                    ),
                    // Markup
                    TextFormField(
                      controller: _markupController,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputMarkup,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Markup';
                        } else if (parseDouble(value) < 0) {
                          return 'Minimal markup 0';
                        } else if (parseDouble(value) > 100) {
                          return 'Maximal markup 100';
                        }
                        return null;
                      },
                      onChanged: onMarkupChange,
                    ),
                    // Jenis Toko
                    DropdownButtonFormField<String>(
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputMerchantType,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      isExpanded: true,
                      value: outletType,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih Jenis Toko';
                        }
                        return null;
                      },
                      onChanged: (newValue) =>
                          setState(() => outletType = newValue),
                      items: outletTypes.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      // add extra sugar..
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 36,
                      // underline: SizedBox(),
                    ),
                    // Address
                    TextFormField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      maxLength: 200,
                      maxLines: 2,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputAddress,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Alamat';
                        } else if (value.length < 10) {
                          return 'Alamat tidak sesuai';
                        }
                        return null;
                      },
                    ),
                    // Button
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 20),
                      child: AppButton(
                          'Kirim',
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
        title: 'Daftar Downline',
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
