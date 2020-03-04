import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/user_service.dart';

class InitScreen extends StatefulWidget {
  InitScreen();

  @override
  _InitState createState() => _InitState();
}

class _InitState extends State<InitScreen> {
  InAppWebViewController webView;

  InAppWebView iaWebView;
  finish(List<dynamic> params) async {
    saveInitDone();
    Navigator.pop(context);
  }

  addHandler() {
    webView.addJavaScriptHandler(handlerName: "FINISH", callback: finish);
  }

  _InitState() {
    iaWebView = InAppWebView(
      initialUrl:
          'https://wizard.jimber.org/?cache_buster=' + Globals().cacheBuster,
      initialHeaders: {},
      initialOptions: InAppWebViewWidgetOptions(
        android: AndroidInAppWebViewOptions(supportMultipleWindows: true),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
        addHandler();
      },
      onCreateWindow:
          (InAppWebViewController controller, OnCreateWindowRequest req) {},
      onLoadStart: (InAppWebViewController controller, String url) {},
      onLoadStop: (InAppWebViewController controller, String url) async {},
      onProgressChanged: (InAppWebViewController controller, int progress) {},
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(child: iaWebView),
    );
  }
}
