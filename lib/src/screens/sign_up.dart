import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/location.dart';
import 'package:miliv2/src/api/login.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/device.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/button.dart';

import '../theme.dart';

class SignUpVerified {
  final bool signedIn;
  final bool verified;
  final String username;
  final String deviceId;
  final String token;
  final String name;

  SignUpVerified(this.signedIn, this.verified, this.username, this.deviceId,
      this.token, this.name);
}

class SignUpScreen extends StatefulWidget {
  final ValueChanged<SignUpVerified> onVerified;
  final Function onBack;

  const SignUpScreen({
    required this.onVerified,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _hasReferral = true;
  String _referral = "";

  final _formKey = GlobalKey<FormState>();

  final _referralController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();

  List<String> outletTypes = [];
  String? outletType;

  List<ProvinceResponse> provinces = [];
  List<CityResponse> cities = [];
  List<DistrictResponse> districts = [];
  List<VillageResponse> villages = [];

  String? filename;
  int? province;
  int? city;
  int? district;
  int? village;

  bool _valid = true;
  late AppAuth authState; // get auth state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   Future.delayed(const Duration(seconds: 1), openPopup);
    //   authState = AppAuthScope.of(context);
    // });
    // _nameController.text = "Mili V2";
    // _phoneController.text = "08123456789";
    // _emailController.text = "miliv2@yopmail.com";
    // _passwordController.text = "password";
    // _passwordConfirmController.text = "password";
    // _addressController.text = "Cimahi 123, Bandung";
  }

  void initialize() {
    getOutletType();
    getProvince();
  }

  void skipReferral() {
    setState(() {
      _hasReferral = false;
    });
  }

  FutureOr<void> _handleError(Object e) {
    snackBarDialog(context, e.toString());
  }

  void verifyReferral() {
    String referral = _referralController.value.text;

    if (referral.isEmpty) {
      setState(() {
        _valid = false;
      });
      return;
    }

    setState(() {
      _valid = true;
    });

    Api.verifyReferral(referral).then((response) {
      setState(() {
        _referral = referral;
      });
    }).catchError(_handleError);
  }

  void getOutletType() {
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

  void getProvince() {
    Api.getProvince().then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      provinces = pagingResponse.data
          .map((dynamic data) =>
              ProvinceResponse.fromJson(data as Map<String, dynamic>))
          .toList();
    }).catchError(_handleError);
  }

  Future<void> getCity() {
    return Api.getCity(province).then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      cities = pagingResponse.data
          .map((dynamic data) =>
              CityResponse.fromJson(data as Map<String, dynamic>))
          .toList();
    }).catchError(_handleError);
  }

  Future<void> getDistrict() {
    return Api.getDistrict(city).then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      districts = pagingResponse.data
          .map((dynamic data) =>
              DistrictResponse.fromJson(data as Map<String, dynamic>))
          .toList();
    }).catchError(_handleError);
  }

  Future<void> getVillage() {
    return Api.getVillage(district).then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      var pagingResponse = PagingResponse.fromJson(bodyMap);

      villages = pagingResponse.data
          .map((dynamic data) =>
              VillageResponse.fromJson(data as Map<String, dynamic>))
          .toList();
    }).catchError(_handleError);
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      var deviceId = await getDeviceId();
      var name = _nameController.value.text;
      var phoneNumber = _phoneController.value.text;
      var email = _emailController.value.text;
      var password = _passwordController.value.text;
      var confirm = _passwordConfirmController.value.text;
      var address = _addressController.value.text;
      var postCode = _postalCodeController.value.text;

      var packageName = await getPackageName();

      Map<String, Object> body = <String, Object>{
        'name': name,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
        'partner': packageName,
        'referral_code': _hasReferral ? _referral : '',
        'outlet_type': outletType!,
        'province': province!,
        'city': city!,
        'district': district!,
        'village': village!,
        'address': address,
        'postCode': postCode,
        'imei': deviceId,
        'guestId': userBalanceState.userId
      };
      debugPrint("Register Request >> ${json.encode(body)}");
      Api.register(body).then((response) {
        Map<String, dynamic>? bodyMap =
            json.decode(response.body) as Map<String, dynamic>?;

        var loginResp = AuthResponse.fromJson(bodyMap!);
        debugPrint("Register Response >> $loginResp");

        widget.onVerified(SignUpVerified(
            true, false, phoneNumber, deviceId, loginResp.token, name));
      }).catchError(_handleError);
    }
  }

  void confirmation() {
    if (_formKey.currentState!.validate()) {
      confirmDialog(
        context,
        title: 'Daftar Akun',
        msg: 'Data yang dimasukkan sudah sesuai ?',
        confirmAction: submit,
        confirmText: 'Ya',
        cancelText: 'Kembali',
      );
    }
  }

  Widget buildReferralForm(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        const Text(
          AppLabel.registrationReferralHeader,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromRGBO(1, 132, 225, 1),
            fontFamily: 'Montserrat',
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
                controller: _referralController,
                textInputAction: TextInputAction.next,
                maxLength: 10,
                cursorColor: Colors.blueAccent,
                decoration: generateInputDecoration(
                  label: AppLabel.registrationInputReferral,
                  color: Colors.blueAccent,
                  errorMsg: !_valid ? AppLabel.errorRequired : null,
                ),
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
                child: AppButton(AppLabel.otpVerify, verifyReferral),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tidak memiliki Kode Referal ? '),
                  TextButton(
                    onPressed: skipReferral,
                    child: const Text('Lewati'),
                    style: textButtonStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRegistrationForm(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                AppLabel.registrationHeader,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(1, 132, 225, 1),
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  letterSpacing:
                      0 /*percentages not used in flutter. defaulting to zero*/,
                  fontWeight: FontWeight.normal,
                  height: 1,
                ),
              ),
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
                        color: Colors.blueAccent,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
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
                        color: Colors.blueAccent,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
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
                        color: Colors.blueAccent,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
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
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      obscureText: true,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputPassword,
                        color: Colors.blueAccent,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan Password';
                        } else if (value.length < 5) {
                          return 'Password tidak sesuai';
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
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputConfirmPassword,
                        color: Colors.blueAccent,
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
                    // Jenis Toko
                    DropdownButtonFormField<String>(
                      decoration: generateInputDecoration(
                        label: AppLabel.registrationInputMerchantType,
                        color: Colors.blueAccent,
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

                    // Provinsi
                    DropdownButtonFormField<int>(
                      decoration: generateInputDecoration(
                        label: AppLabel.upgradeInputProvince,
                        color: Colors.blueAccent,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      isExpanded: true,
                      value: province,
                      validator: (value) {
                        if (value == null) {
                          return '${AppLabel.upgradeInputProvince} harus dipilih';
                        }
                        return null;
                      },
                      onChanged: provinces.isEmpty
                          ? null
                          : (newValue) async {
                              province = newValue;
                              if (province != null) {
                                await getCity();
                              } else {
                                cities = [];
                              }
                              setState(() {});
                            },
                      items: provinces.map<DropdownMenuItem<int>>((province) {
                        return DropdownMenuItem<int>(
                          value: province.serverId,
                          child: Text(province.provinceName),
                        );
                      }).toList(),
                      // add extra sugar..
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 36,
                      // underline: SizedBox(),
                    ),
                    // Kab Kota
                    DropdownButtonFormField<int>(
                      decoration: generateInputDecoration(
                        label: AppLabel.upgradeInputCity,
                        color: Colors.blueAccent,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      isExpanded: true,
                      value: city,
                      validator: (value) {
                        if (value == null) {
                          return '${AppLabel.upgradeInputCity} harus dipilih';
                        }
                        return null;
                      },
                      onChanged: cities.isEmpty
                          ? null
                          : (newValue) async {
                              city = newValue;
                              if (city != null) {
                                await getDistrict();
                              } else {
                                cities = [];
                              }
                              setState(() {});
                            },
                      items: cities.map<DropdownMenuItem<int>>((item) {
                        return DropdownMenuItem<int>(
                          value: item.serverId,
                          child: Text(item.cityName),
                        );
                      }).toList(),
                      // add extra sugar..
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 36,
                      // underline: SizedBox(),
                    ),
                    // Kecamatan
                    DropdownButtonFormField<int>(
                      decoration: generateInputDecoration(
                        label: AppLabel.upgradeInputDistrict,
                        color: Colors.blueAccent,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      isExpanded: true,
                      value: district,
                      validator: (value) {
                        if (value == null) {
                          return '${AppLabel.upgradeInputDistrict} harus dipilih';
                        }
                        return null;
                      },
                      onChanged: districts.isEmpty
                          ? null
                          : (newValue) async {
                              district = newValue;
                              if (district != null) {
                                await getVillage();
                              } else {
                                cities = [];
                              }
                              setState(() {});
                            },
                      items: districts.map<DropdownMenuItem<int>>((item) {
                        return DropdownMenuItem<int>(
                          value: item.serverId,
                          child: Text(item.districtName),
                        );
                      }).toList(),
                      // add extra sugar..
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 36,
                      // underline: SizedBox(),
                    ),
                    // Keluarahan
                    DropdownButtonFormField<int>(
                      decoration: generateInputDecoration(
                        label: AppLabel.upgradeInputVillage,
                        color: Colors.blueAccent,
                        // errorMsg: !_valid ? AppLabel.errorRequired : null,
                      ),
                      isExpanded: true,
                      value: village,
                      validator: (value) {
                        if (value == null) {
                          return '${AppLabel.upgradeInputVillage} harus dipilih';
                        }
                        return null;
                      },
                      onChanged: villages.isEmpty
                          ? null
                          : (newValue) => setState(() => village = newValue),
                      items: villages.map<DropdownMenuItem<int>>((item) {
                        return DropdownMenuItem<int>(
                          value: item.serverId,
                          child: Text(item.villageName),
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
                        color: Colors.blueAccent,
                        errorMsg: !_valid ? AppLabel.errorRequired : null,
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
                    // Postal Code
                    TextFormField(
                      controller: _postalCodeController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 5,
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.upgradeInputPostalCode,
                        color: Colors.blueAccent,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '${AppLabel.upgradeInputPostalCode} tidak boleh kosong';
                        } else if (value.length != 5) {
                          return '${AppLabel.upgradeInputPostalCode} tidak sesuai';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    // Button
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 20),
                      child:
                          AppButton(AppLabel.registrationSubmit, confirmation),
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
      appBar: AppBar(
        title: const Text(
          AppLabel.registrationTitle,
          style: TextStyle(color: Colors.blueAccent),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.blueAccent,
          ),
          tooltip: AppLabel.backNavigation,
          onPressed: () {
            // Navigator.maybePop(context);
            // authState.signOut();
            // routeState.go('/signin');
            widget.onBack();
          },
        ),
        elevation: 0,
      ),
      body: _hasReferral && _referral.isEmpty
          ? buildReferralForm(context)
          : buildRegistrationForm(context),
    );
  }

  @override
  void dispose() {
    // stopTimer();
    super.dispose();
  }
}
