import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miliv2/src/api/api.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RewardScreen extends StatefulWidget {
  final String title;
  final String url;

  const RewardScreen({Key? key, required this.title, required this.url}) : super(key: key);

  @override
  _RewardScreenState createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  var loadingPercentage = 0;
  var termAccepted = false;
  var step = 1;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView(); // AndroidWebView()
    }
  }

  Widget buildContent(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          WebView(
            initialUrl: widget.url,
            zoomEnabled: false,
            javascriptMode: JavascriptMode.unrestricted,
            onWebResourceError: (error) {
              debugPrint('RewardScreen error $error');
            },
            onWebViewCreated: (webViewController) {
              _controller.complete(webViewController);
              webViewController.loadUrl(
                widget.url,
                headers: Api.getRequestHeaders(),
              );
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
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
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
      body: buildContent(context),
    );
  }
}
