import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class InitScreen extends StatefulWidget {
  InitScreen();

  @override
  _InitState createState() => _InitState();
}

class _InitState extends State<InitScreen> {
  late InAppWebViewController webView;
  late InAppWebView iaWebView;

  finish(List<dynamic> params) async {
    print("**** LOAD DONE ");
    saveInitDone();
    Navigator.pop(context, true);
  }

  addHandler() {
    webView.addJavaScriptHandler(handlerName: "FINISH", callback: finish);
  }

  _InitState() {
    iaWebView = InAppWebView(
      initialUrlRequest: URLRequest(
          url: Uri.parse(AppConfig().wizardUrl() +
              '?cache_buster=' +
              new DateTime.now().millisecondsSinceEpoch.toString())),
      initialOptions: InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(supportMultipleWindows: true, useHybridComposition: true),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
        addHandler();
      },
      onCreateWindow: (InAppWebViewController controller, CreateWindowAction req) {
        return Future.value(true);
      },
      onLoadStart: (InAppWebViewController controller, Uri? url) {},
      onLoadStop: (InAppWebViewController controller, Uri? url) async {},
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
