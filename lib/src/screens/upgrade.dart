import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/api/location.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UpgradeScreen extends StatefulWidget {
  final String title;
  final bool allowUpgrade;

  const UpgradeScreen({
    Key? key,
    required this.title,
    this.allowUpgrade = true,
  }) : super(key: key);

  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  var loadingPercentage = 0;
  var termAccepted = false;
  var step = 1;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  final _formKey = GlobalKey<FormState>();

  final _idCardController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();

  List<ProvinceResponse> provinces = [];
  List<CityResponse> cities = [];
  List<DistrictResponse> districts = [];
  List<VillageResponse> villages = [];

  Uint8List? photoByte;
  String? filename;
  int? province;
  int? city;
  int? district;
  int? village;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView(); // AndroidWebView();
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getProvince();
    });
  }

  FutureOr<void> _handleError(Object e) {
    snackBarDialog(context, e.toString());
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

  void acceptTerm() {
    step += 1;
    setState(() {});
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      var idCard = _idCardController.value.text;
      var postCode = _postalCodeController.value.text;
      var address = _addressController.value.text;

      Api.upgrade(
        idCardNumber: idCard,
        postCode: postCode,
        province: province!,
        city: city!,
        district: district!,
        village: village!,
        address: address,
        photo: photoByte,
      ).then((response) async {
        final respStr = await response.stream.bytesToString();
        final body = json.decode(respStr) as Map<String, dynamic>;
        debugPrint('Upgrade Account res ${response.statusCode} $body');
        // var status = response.statusCode;
        // if (status == 200) {
        //   userBalanceState.fetchData();
        // }
        if (response.statusCode == 200) {
          await userBalanceState.fetchData();
          popScreen(context);
        } else {
          snackBarDialog(
              context,
              (body['error_msg'] ??
                      'Pendaftaran gagal, pastikan data sudah lengkap dan sesuai.')
                  .toString());
        }
      }).catchError(_handleError);
    }
  }

  void confirmation() {
    if (_formKey.currentState!.validate()) {
      confirmDialog(context,
          title: 'Upgrade Akun',
          msg: 'Lanjutkan pendaftaran ?',
          confirmAction: submit,
          confirmText: 'Ya, lanjutkan',
          cancelText: 'Batal');
    }
  }

  void pickImage(ImageSource source) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxHeight: 1024,
      maxWidth: 1024,
      source: source,
    );

    if (result != null) {
      File? croppedFile = await ImageCropper.cropImage(
          sourcePath: result.path,
          aspectRatioPresets: [
            // CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            // CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.lightBlueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null) {
        photoByte = await croppedFile.readAsBytes();
        setState(() {});
      }
    }
  }

  VoidCallback onPhotoTap(BuildContext context) {
    return () async {
      ImageSource? source = await showDialog<ImageSource>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Pilih Foto'),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                  child: Text('Ambil dari Kamera',
                      style: Theme.of(context).textTheme.subtitle1),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                  child: Text('Ambil dari Galeri',
                      style: Theme.of(context).textTheme.subtitle1),
                ),
              ],
            );
          });

      if (source == null) {
        return;
      }

      pickImage(source);
    };
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ID Card
                    TextFormField(
                      controller: _idCardController,
                      textInputAction: TextInputAction.next,
                      maxLength: 16,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      cursorColor: Colors.blueAccent,
                      decoration: generateInputDecoration(
                        label: AppLabel.upgradeInputIdCard,
                        color: Colors.blueAccent,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.attach_file_rounded),
                          onPressed: onPhotoTap(context),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '${AppLabel.upgradeInputIdCard} tidak boleh kosong';
                        } else if (value.length != 16) {
                          return '${AppLabel.upgradeInputIdCard} tidak sesuai';
                        } else if (photoByte == null) {
                          return 'Upload file';
                        }
                        return null;
                      },
                    ),
                    photoByte != null
                        ? Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: Colors.black12),
                                borderRadius: const BorderRadius.all(
                                    Radius.elliptical(5, 5))),
                            child: Image.memory(
                              photoByte!,
                              isAntiAlias: true,
                            ),
                          )
                        : const SizedBox(),
                    // Row(
                    //   children: [
                    //     // IconButton(
                    //     //   icon: const Icon(Icons.attach_file_rounded),
                    //     //   onPressed: () {},
                    //     // )
                    //   ],
                    // ),

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
                        label: AppLabel.upgradeInputAddress,
                        color: Colors.blueAccent,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '${AppLabel.upgradeInputAddress} tidak boleh kosong';
                        } else if (value.length < 10) {
                          return '${AppLabel.upgradeInputAddress} tidak sesuai';
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
                      child: AppButton('Daftar', confirmation),
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

  Widget buildTerm() {
    return SafeArea(
      child: Column(
        children: [
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
          Expanded(
            child: AppConfig.devMode
                ? Container(
                    color: Colors.grey,
                  )
                : WebView(
                    initialUrl: 'https://www.mymili.id/upgrade-premium/',
                    zoomEnabled: true,
                    onWebResourceError: (error) {
                      debugPrint('PrivacyScreen error $error');
                    },
                    onWebViewCreated: (webViewController) {
                      _controller.complete(webViewController);
                    },
                    onPageStarted: (url) {
                      setState(() {
                        loadingPercentage = 0;
                      });
                    },
                    onProgress: (progress) {
                      setState(() {
                        loadingPercentage = progress;
                      });
                    },
                    onPageFinished: (url) {
                      setState(() {
                        loadingPercentage = 100;
                      });
                    },
                  ),
          ),
          widget.allowUpgrade
              ? Container(
                  color: AppColors.white1,
                  width: double.infinity,
                  height: 150,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text(
                            'Setuju dengan syarat & ketentuan yang berlaku'),
                        value: termAccepted,
                        onChanged: (value) {
                          if (value == null) {
                            termAccepted = false;
                          } else {
                            termAccepted = value;
                          }
                          setState(() {});
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      AppButton(
                        'Lanjutkan Pendaftaran',
                        !termAccepted ? null : acceptTerm,
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SimpleAppBar2(
          title: widget.title,
        ),
        body: step == 1 ? buildTerm() : buildForm(context));
  }
}
