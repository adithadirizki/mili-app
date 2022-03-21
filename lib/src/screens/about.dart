import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miliv2/src/config/config.dart';
import 'package:miliv2/src/widgets/app_bar_1.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AboutScreen extends StatefulWidget {
  final String title;

  const AboutScreen({Key? key, required this.title}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView(); // AndroidWebView()
    }
    super.initState();
  }

  var loadingPercentage = 0;

  Widget buildContent(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          AppConfig.devMode
              ? Container(
                  color: Colors.grey,
                )
              : WebView(
                  initialUrl: 'https://www.mymili.id/tentang-aplikasi/',
                  zoomEnabled: true,
                  onWebResourceError: (error) {
                    debugPrint('AboutScreen error $error');
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
