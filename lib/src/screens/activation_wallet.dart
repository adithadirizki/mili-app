import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/services/auth.dart';
import 'package:miliv2/src/theme/style.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:miliv2/src/widgets/pin_verification.dart';

import '../theme.dart';

class ActivationWalletScreen extends StatefulWidget {
  final String title;
  const ActivationWalletScreen({
    Key? key,
    this.title = 'Aktivasi Finpay',
  }) : super(key: key);

  @override
  _ActivationWalletScreenState createState() => _ActivationWalletScreenState();
}

class _ActivationWalletScreenState extends State<ActivationWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final walletOTPState = GlobalKey<PINVerificationState>();

  final _nameController = TextEditingController();

  late AppAuth authState; // get auth state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() {
    confirmDialog(context,
        title: 'Aktivasi Finpay',
        msg:
            'Finpay adalah dompet digital yang sudah terdaftar OJK, dengan menggunakan Finpay Anda dapat melakukan semua pembayaran digital dan semua pembayaran QRIS. Kemudahan topup saldo menggunakan Virtual Account dan kelebihan lainnya.\n\n'
            'Saldo Mili saat ini akan diubah kedalam saldo Finpay. Pastikan data yang dimasukkan adalah data yang sesuai dengan identitas pribadi.\n\n'
            'Dengan melanjutkan Anda memahami dan menjamin data yang dimasukkan adalah yang sesungguhnya. Lanjutkan ?',
        cancelAction: () {
      popScreen(context);
    }, confirmText: 'Lanjutkan', confirmAction: () {});
  }

  FutureOr<void> _handleError(Object e) {
    isLoading = false;
    setState(() {});
    snackBarDialog(context, e.toString());
  }

  // Begin Finpay related function
  void openWalletOtp() {
    pushScreen(
      context,
      (_) => PINVerification.withGradientBackground(
        key: walletOTPState,
        otpLength: 6,
        secured: false,
        title: 'Aktivasi Finpay',
        subTitle: 'Masukkan Kode OTP',
        invalidMessage: 'Kode OTP tidak sesuai',
        validateOtp: (otp) async {
          return Api.walletConfirmation(otp).then((response) {
            return true;
          }).catchError((Object e) {
            _handleError(e);
            return false;
          });
        },
        onValidateSuccess: (ctx) async {
          walletOTPState.currentState!.clearOtp();
          userBalanceState.fetchData();
          snackBarDialog(context, 'Akun Finpay berhasil diaktivasi');
          await popScreen(context);
        },
        onInvalid: (_) {
          walletOTPState.currentState!.clearOtp();
        },
        topColor: const Color.fromRGBO(0, 255, 193, 1),
        bottomColor: const Color.fromRGBO(0, 10, 255, 0.9938945174217224),
        themeColor: Colors.white,
        titleColor: Colors.white,
        // icon: Image.asset(
        //   'images/phone_logo.png',
        //   fit: BoxFit.fill,
        // ),
      ),
    );
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      var fullname = _nameController.value.text;
      isLoading = true;
      setState(() {});
      Api.walletActivation(fullname).then((response) {
        openWalletOtp();
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
      appBar: SimpleAppBar2(
        title: widget.title,
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
