import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/Apps/Wallet/walletUserData.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/RegistrationScreen.dart';

import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/toolsService.dart';
import 'package:threebotlogin/services/userService.dart';

import 'WalletConfig.dart';

bool created = false;

class WalletWidget extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<WalletWidget>
    with AutomaticKeepAliveClientMixin {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  var config = WalletConfig();
  InAppWebView iaWebView;

  _WalletState() {
    iaWebView = InAppWebView(
      initialUrl:  'http://192.168.0.221:8080/handlertest.html?nocache=3', //'https://${config.appId()}',
      initialHeaders: {},
      initialOptions: InAppWebViewWidgetOptions(
          android: AndroidInAppWebViewOptions(supportMultipleWindows: true)),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
        this.addHandler();
      //  initKeys();
      },
      onCreateWindow:
          (InAppWebViewController controller, OnCreateWindowRequest req) {
      },
      onLoadStart: (InAppWebViewController controller, String url) {
        setState(() {
          this.url = url;
        });
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
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
    scope['derivedSeed'] = await getDerivedSeed(config.appId());
    var encrypted =
        await encrypt(jsonEncode(scope), keys["publicKey"], privateKey);
    var jsonData = jsonEncode(encrypted);
    var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();

    var loadUrl =
        'https://${config.appId()}${config.redirectUrl()}${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(signedHash)}&data=$data';

    webView.loadUrl(url: loadUrl);
  }

  scanQrCode(List<dynamic> params) async {
      dynamic result = await Navigator.pushNamed(context, '/scan');
      print("got result");
      print(result);
      return result;
  }
  addHandler() {
    webView.addJavaScriptHandler(
        handlerName: "ADD_IMPORT_WALLET", callback: saveImportedWallet);
    webView.addJavaScriptHandler(
        handlerName: "ADD_APP_WALLET", callback: saveAppWallet);
    webView.addJavaScriptHandler(
      handlerName: "SCAN_QR", callback: scanQrCode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container( child: iaWebView),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
