import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/data/user_balance.dart';
import 'package:miliv2/src/screens/tos_finpay.dart';
import 'package:miliv2/src/theme.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TopupWalletScreen extends StatefulWidget {
  final String title;

  const TopupWalletScreen({
    Key? key,
    this.title = 'Topup Saldo',
  }) : super(key: key);

  @override
  _TopupWalletScreenState createState() => _TopupWalletScreenState();
}

class _TopupWalletScreenState extends State<TopupWalletScreen> {
  var loadingPercentage = 0;
  var termAccepted = false;
  var step = 1;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  String? widgetUrl;
  List? topupInfo;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView(); // AndroidWebView();
    }
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initialize();
    });
  }

  void initialize() {
    void handleResponseInfo(http.Response response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      topupInfo = bodyMap['message'] as List;
      setState(() {});
    }

    Api.walletTopupInfo().then(handleResponseInfo).catchError(_handleError);

    Api.walletTopup().then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      debugPrint('getWidgetUrl $bodyMap');
      widgetUrl = bodyMap['url']?.toString();
      setState(() {});
    }).catchError(_handleError);
  }

  FutureOr<void> _handleError(dynamic e) {
    snackBarDialog(context, e.toString());
  }

  Widget buildWidget() {
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
              javascriptMode: JavascriptMode.unrestricted,
              onWebResourceError: (error) {
                debugPrint('TopupWallet error $error');
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
          topupInfo != null
              ? Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: topupInfo
                        ?.map((dynamic e) => Text(
                              e['text'].toString(),
                              style: TextStyle(
                                fontWeight: e['important'] == true
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                                height: 1.7,
                              ),
                            ))
                        .toList() as List<Widget>,
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
        appBar: SimpleAppBar(
          title: widget.title,
          actions: [
            GestureDetector(
              onTap: () {
                pushScreen(
                  context,
                  (_) => TosFinpayScreen(
                    title: userBalanceState.walletPremium
                        ? 'Akun Premium'
                        : 'Upgrade Premium Finpay',
                    walletActive: userBalanceState.walletActive,
                    walletPremium: userBalanceState.walletPremium,
                  ),
                );
              },
              child: userBalanceState.walletPremium
                  ? const Image(image: AppImages.finpayPremium, width: 80)
                  : const Image(image: AppImages.finpayBasic, width: 80),
            ),
            const SizedBox(width: 15),
          ],
        ),
        body: buildWidget());
  }
}
