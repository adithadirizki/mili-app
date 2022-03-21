import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewContainer extends StatefulWidget {
  final String url;

  const WebviewContainer({Key? key, required this.url}) : super(key: key);

  @override
  _WebviewContainerState createState() => _WebviewContainerState();
}

class _WebviewContainerState extends State<WebviewContainer> {
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Expanded(
              child: WebView(
                initialUrl: widget.url,
                zoomEnabled: true,
                onWebResourceError: (error) {
                  debugPrint('PrivacyScreen error $error');
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
                  // onPageFinished: (url) {
                  //   setState(() {
                  //     loadingPercentage = 100;
                  //   });
                },
              ),
            ),
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100.0,
              ),
          ],
        ),
      ),
    );
  }
}
