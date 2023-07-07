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
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  late WebViewController _webViewController;
  bool _canGoBack = false;

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
            onWebViewCreated: (webViewController) {
              _webViewController = webViewController;
              _controller.complete(webViewController);
              webViewController.loadUrl(
                widget.url,
                headers: Api.getRequestHeaders(),
              );
            },
            gestureNavigationEnabled: true,
            navigationDelegate: (request) {
              _webViewController.loadUrl(
                request.url,
                headers: Api.getRequestHeaders(),
              );
              return NavigationDecision.prevent;
            },
            onPageFinished: (url) async {
              _canGoBack = await _webViewController.canGoBack();
              loadingPercentage = 100;
              setState(() {});
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
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
          // if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: SimpleAppBar2(
          title: widget.title,
        ),
        body: buildContent(context),
      ),
      onWillPop: () async {
        if (_canGoBack) {
          _webViewController.goBack();
          return false;
        }
        return true;
      },
    );
  }
}
