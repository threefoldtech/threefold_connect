import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  bool isLoading = true;
  late WebViewController controller;
  final termsAndConditionsUrl = Globals().termsAndConditionsUrl;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (error) {
            logger.e('Error loading: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(termsAndConditionsUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
