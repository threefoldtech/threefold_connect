import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpConfig.dart';
import 'package:threebotlogin/Browser.dart';

import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/userService.dart';

/**************** */


/*
Future main() async {
  runApp(new FfpWidget());
}*/

class FfpWidget extends StatefulWidget {
  @override
  _FfpState createState() => new _FfpState();
}

class _FfpState extends State<FfpWidget> with AutomaticKeepAliveClientMixin {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  FfpConfig config = FfpConfig();

  InAppWebView iaWebview;
  _FfpState() {
    iaWebview = InAppWebView(
      initialUrl: config.cookieUrl(),
      initialHeaders: {},
      initialOptions: InAppWebViewWidgetOptions(),
      onLoadStart: (InAppWebViewController controller, String url) {
        if (url.contains('state=')) {
          controller.injectCSSCode(source: '* { display: none; }');
        }
        controller.injectCSSCode(
            source: ".crisp-client {display: none !important;}");
        setState(() {
          this.url = url;
        });
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        controller.injectCSSCode(
            source: ".crisp-client {display: none !important;}");
        setState(() {
          this.url = url;
        });
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        setState(() {
          this.progress = progress / 100;
        });
      },
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

  initKeys() async {
    var url = await webView.getUrl();
    while (!url.contains('state')) {
      url = await webView.getUrl();
    }

    final state = Uri.decodeFull(url.split("&state=")[1]);
    final union = '?';
    final privateKey = await getPrivateKey();
    final signedHash = signData(state, privateKey);

    final redirecturl =
        Uri.decodeFull(url.split("&redirecturl=")[1].split("&")[0]);
    final scope = Uri.decodeFull(url.split("&scope=")[1].split("&")[0]);
    final publickey = Uri.decodeFull(url.split("&publickey=")[1].split("&")[0]);

    final scopeData = {};

    if (scope != null && scope.contains("\"email\":")) {
      scopeData['email'] = await getEmail();
      print("adding scope");
    }

    var jsonData = jsonEncode(
        (await encrypt(jsonEncode(scopeData), publickey, privateKey)));
    var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();
    var loadUrl =
        'https://${config.appId()}${redirecturl}${union}username=${await getDoubleName()}&signedhash=${Uri.encodeComponent(await signedHash)}&data=$data';

    webView.loadUrl(url: loadUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(child: iaWebview),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
