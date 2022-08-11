import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';

import '../theme.dart';

class ProfileUpdateScreen extends StatefulWidget {
  // final ValueChanged<ProfileUpdateScreen> onVerified;
  // final Function onBack;

  const ProfileUpdateScreen({
    // required this.onVerified,
    // required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  List<String> outletTypes = [];
  String? outletType = 'Lainnya';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = userBalanceState.name;
    _phoneController.text = userBalanceState.phoneNumber;
    _emailController.text = userBalanceState.email;
    _addressController.text = userBalanceState.address ?? '';
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() {
    Api.getOutletType().then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);
      outletTypes = pagingResponse.data.map<String>((dynamic data) {
        return ((data as Map<String, dynamic>)['key']! as String);
      }).toList();
      if (outletTypes.contains(userBalanceState.outletType)) {
        outletType = userBalanceState.outletType;
      }
      setState(() {});
    }).catchError(_handleError);
  }

  FutureOr<void> _handleError(dynamic e) {
    isLoading = false;
    setState(() {});
    snackBarDialog(context, e.toString());
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      var name = _nameController.value.text;
      var phoneNumber = _phoneController.value.text;
      var email = _emailController.value.text;
      var address = _addressController.value.text;

      Map<String, Object> body = <String, Object>{
        'nama': name,
        'hp': phoneNumber,
        'email': email,
        'outlet_type': outletType!,
        'address': address,
      };
      debugPrint("Request >> ${json.encode(body)}");
      isLoading = true;
      setState(() {});
      Api.updateProfile(body).then((response) {
        Map<String, dynamic>? bodyMap =
            json.decode(response.body) as Map<String, dynamic>?;
        debugPrint("Response >> $bodyMap");
        var status = response.statusCode;
        if (status == 200) {
          userBalanceState.fetchData();
        }
        snackBarDialog(context, 'Profile berhasil diubah');
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
                    // Name
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      cursorColor: AppColors.gold3,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputName,
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
                      cursorColor: AppColors.gold3,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputPhone,
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
                      controller: _emailController,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      cursorColor: AppColors.gold3,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputEmail,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Email';
                        }
                        return null;
                      },
                    ),
                    // Jenis Toko
                    // DropdownButtonFormField<String>(
                    //   decoration: generateInputDecoration(
                    //     label: AppLabel.registrationInputMerchantType,
                    //   ),
                    //   isExpanded: true,
                    //   value: outletType,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Pilih Jenis Toko';
                    //     }
                    //     return null;
                    //   },
                    //   onChanged: (newValue) =>
                    //       setState(() => outletType = newValue),
                    //   items: outletTypes.map<DropdownMenuItem<String>>((value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),
                    //     );
                    //   }).toList(),
                    //   // add extra sugar..
                    //   icon: const Icon(Icons.arrow_drop_down),
                    //   iconSize: 36,
                    //   // underline: SizedBox(),
                    // ),
                    // Address
                    TextFormField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      maxLength: 200,
                      maxLines: 2,
                      cursorColor: AppColors.gold3,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputAddress,
                      ),
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
        title: 'Perbarui Data',
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
