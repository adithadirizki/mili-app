import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileWalletScreen extends StatefulWidget {
  final String title;

  const ProfileWalletScreen({
    Key? key,
    this.title = 'Akun MyFinPay',
  }) : super(key: key);

  @override
  _ProfileWalletScreenState createState() => _ProfileWalletScreenState();
}

class _ProfileWalletScreenState extends State<ProfileWalletScreen> {
  var loadingPercentage = 0;
  var termAccepted = false;
  var step = 1;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  String? widgetUrl;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView(); // AndroidWebView();
    }
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      getWidgetUrl();
    });
  }

  FutureOr<void> _handleError(dynamic e) {
    snackBarDialog(context, e.toString());
  }

  void getWidgetUrl() {
    Api.walletProfile().then((response) {
      Map<String, dynamic> bodyMap =
          json.decode(response.body) as Map<String, dynamic>;
      debugPrint('getWidgetUrl $bodyMap');
      widgetUrl = bodyMap['url']?.toString();
      setState(() {});
    }).catchError(_handleError);
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
            child: AppConfig.devMode && false
                ? Container(
                    color: Colors.grey,
                  )
                : WebView(
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SimpleAppBar(
          title: widget.title,
        ),
        body: buildWidget());
  }
}
