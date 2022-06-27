import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/utils/dialog.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QrisPaymentScreen extends StatefulWidget {
  final String title;
  final String paymentCode;

  const QrisPaymentScreen({
    Key? key,
    this.title = 'QRIS Payment', required this.paymentCode,
  }) : super(key: key);

  @override
  _QrisPaymentScreenState createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
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
    Api.walletPayment(widget.paymentCode).then((response) {
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
                      debugPrint('QrisPayment error $error');
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
        appBar: SimpleAppBar2(
          title: widget.title,
        ),
        body: buildWidget());
  }
}
