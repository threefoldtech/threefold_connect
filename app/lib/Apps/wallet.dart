import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/toolsService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomScaffold.dart';

import '../main.dart';
/*
Future main() async {
  runApp(new Wallet());
}*/

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => new _WalletState();
}

class _WalletState extends State<Wallet> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  String appId = "https://wallet.staging.jimber.org/";
  String redirectUrl = "/login";

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  initKeys() async {
    final union = '?';

    var keys = await generateKeyPair();

    final state = randomString(15);

    final privateKey = await getPrivateKey();
    final signedHash = await signData(state, privateKey);

    var jsToExecute =
        "(function() { try {window.localStorage.setItem('tempKeys', \'{\"privateKey\": \"${keys["privateKey"]}\", \"publicKey\": \"${keys["publicKey"]}\"}\');  window.localStorage.setItem('state', '$state'); } catch (err) { return err; } })();";

    webView.evaluateJavascript(source: jsToExecute);

    var scope = {};
    scope['doubleName'] = await getDoubleName();
    scope['derivedSeed'] = await getDerivedSeed(appId);
    var encrypted =
        await encrypt(jsonEncode(scope), keys["publicKey"], privateKey);
    var jsonData = jsonEncode(encrypted);
    var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();

    var loadUrl =
        'https://$appId$redirectUrl${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(signedHash)}&data=$data';
    logger.log("!!!loadUrl: " + loadUrl);

    webView.loadUrl(url: loadUrl);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: InAppWebView(
                initialUrl: "https://wallet.staging.jimber.org",
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
    );
  }
}
