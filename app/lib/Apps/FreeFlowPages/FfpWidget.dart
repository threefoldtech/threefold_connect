import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpConfig.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpEvents.dart';
import 'package:threebotlogin/ClipboardHack/ClipboardHack.dart';
import 'package:threebotlogin/Events/Events.dart';

import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/userService.dart';

class FfpWidget extends StatefulWidget {
  @override
  _FfpState createState() => new _FfpState();
}

class _FfpState extends State<FfpWidget>
    with AutomaticKeepAliveClientMixin {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  FfpConfig config = FfpConfig();

  InAppWebView iaWebview;
  _FfpState() {
    iaWebview = new InAppWebView(
      initialUrl: config.cookieUrl(),
      initialHeaders: {},
      initialOptions: InAppWebViewWidgetOptions(),
      onLoadStart: (InAppWebViewController controller, String url) {
        webView = controller;
         if (url.contains('state')){
           controller.stopLoading();
         }
        initKeys(url);
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        if (!mounted) return;
        controller.injectCSSCode(
            source: ".crisp-client {display: none !important;}");
        addClipboardHack(controller);
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {},
    );
    Events().onEvent(FfpBrowseEvent().runtimeType, _browseToUrl);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _browseToUrl(FfpBrowseEvent event) {
    if (this.webView != null) {
      this.webView.loadUrl(url: event.url);
    }
  }

  initKeys(String url) async {
    if (!url.contains('state') || url.contains('threebot://')) {
      return;
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
    if (this.iaWebview == null) {
      return null;
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(child: iaWebview),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
