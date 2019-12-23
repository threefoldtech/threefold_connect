import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'config.dart';
/*
Future main() async {
  runApp(new FfpWidget());
}*/

class FfpWidget extends StatefulWidget {
  @override
  _WalletState createState() => new _WalletState();
}

class _WalletState extends State<FfpWidget> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  FfpConfig config = FfpConfig();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initKeys() async {
    var url = await webView.getUrl(); // get url after login redir

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
    return MaterialApp(
      home: new Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: InAppWebView(
                  initialUrl: config.cookieUrl(),
                  initialHeaders: {},
                  initialOptions: InAppWebViewWidgetOptions(),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                    initKeys();
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    setState(() {
                      this.url = url;
                    });
                  },
                  onLoadStop:
                      (InAppWebViewController controller, String url) async {
                    setState(() {
                      this.url = url;
                    });
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
