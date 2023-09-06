import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miliv2/src/screens/activation_wallet.dart';
import 'package:miliv2/src/screens/upgrade_wallet.dart';
import 'package:miliv2/src/theme/colors.dart';
import 'package:miliv2/src/theme/images.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:miliv2/src/widgets/button.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TosFinpayScreen extends StatefulWidget {
  final String title;
  final bool walletActive;
  final bool walletPremium;

  const TosFinpayScreen({
    Key? key,
    required this.title,
    required this.walletActive,
    required this.walletPremium,
  }) : super(key: key);

  @override
  _TosFinpayScreenState createState() => _TosFinpayScreenState();
}

class _TosFinpayScreenState extends State<TosFinpayScreen> {
  var loadingPercentage = 0;
  var termAccepted = false;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  String? widgetUrl;
  String finpayUpBasicUrl = 'https://www.mymili.id/basic-finpay/';
  String finpayUpPremiumUrl = 'https://www.mymili.id/premium-finpay/';
  String finpayPremiumUrl =
      'https://www.mymili.id/sudah-upgrade-premium-finpay/';

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView(); // AndroidWebView();
    }
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          if (widget.walletActive) {
            widgetUrl = widget.walletPremium
                ? finpayPremiumUrl
                : finpayUpPremiumUrl;
          } else {
            widgetUrl = finpayUpBasicUrl;
          }
        });
      });
    });
  }

  void acceptTerm() {
    if (!widget.walletActive) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const ActivationWalletScreen(),
        ),
      );
    } else if (!widget.walletPremium) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const UpgradeWalletScreen(),
        ),
      );
    } else {
      snackBarDialog(context, 'Akun Anda sudah premium');
    }
  }

  Widget buildTerm() {
    if (widgetUrl == null) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }
    return SafeArea(
      child: Column(
        children: [
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
          Expanded(
            child: WebView(
              initialUrl: widgetUrl,
              zoomEnabled: true,
              onWebResourceError: (error) {
                debugPrint('TosFinpayScreen error $error');
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
          widget.walletPremium
              ? const SizedBox()
              : Container(
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
                        !widget.walletActive
                            ? 'Lanjutkan Pendaftaran'
                            : !widget.walletPremium
                                ? 'Lanjutkan Upgrade'
                                : 'Lanjutkan',
                        !termAccepted ? null : acceptTerm,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar2(
        title: widget.title,
        actions: const [
          Image(
            image: AppImages.logoWallet,
            width: 40,
          ),
          SizedBox(width: 15),
        ],
      ),
      body: buildTerm(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
