import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RewardMeScreen extends StatefulWidget {
  final String title;
  final String widgetUrl;

  const RewardMeScreen({Key? key, required this.title, required this.widgetUrl}) : super(key: key);

  @override
  _RewardMeScreenState createState() => _RewardMeScreenState();
}

class _RewardMeScreenState extends State<RewardMeScreen> {
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
      WebView.platform = SurfaceAndroidWebView(); // AndroidWebView()
    }
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          widgetUrl = widget.widgetUrl;
        });
      });
    });
  }

  Widget buildContent(BuildContext context) {
    if (widgetUrl == null) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }
    return SafeArea(
      child: Stack(
        children: [
          WebView(
            initialUrl: widgetUrl,
            zoomEnabled: true,
            javascriptMode: JavascriptMode.unrestricted,
            onWebResourceError: (error) {
              debugPrint('RewardMeScreen error $error');
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
