import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/main.dart';

class InitWidget extends StatefulWidget {
  AppWidget main;
  InitWidget(AppWidget main) {
    this.main = main;
  }
  @override
  _InitState createState() => _InitState(main);
}

class _InitState extends State<InitWidget> with AutomaticKeepAliveClientMixin {
  InAppWebViewController webView;
  AppWidget main;
  InAppWebView iaWebView;
  finish(List<dynamic> params) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('initDone', true);
    main.finish();
  }

  addHandler() {
    webView.addJavaScriptHandler(handlerName: "FINISH", callback: finish);
  }

  _InitState(AppWidget main) {
    this.main = main;

    iaWebView = InAppWebView(
      initialUrl: 'https://www.jimber.org/wizardnew?nocache=3',
      initialHeaders: {},
      initialOptions: InAppWebViewWidgetOptions(
          android: AndroidInAppWebViewOptions(supportMultipleWindows: true)),
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
