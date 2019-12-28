import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/Apps/Wallet/walletUserData.dart';
import 'package:threebotlogin/ClipboardHack/ClipboardHack.dart';
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
        initialUrl: //'http://192.168.2.90:8080/handlertest.html?nocache',//
            'http://192.168.2.120:8080/error?cache=2', //'https://${config.appId()}', //http://192.168.2.120:8080/', //'http://192.168.0.221:8080/handlertest.html?nocache=3',
        initialHeaders: {},
        initialOptions: InAppWebViewWidgetOptions(
            crossPlatform: InAppWebViewOptions(debuggingEnabled: true),
            android: AndroidInAppWebViewOptions(
                supportMultipleWindows: true, thirdPartyCookiesEnabled: true)),
        onWebViewCreated: (InAppWebViewController controller) {
          webView = controller;
          this.addHandler();
          initKeys();
          initWallets();
        },
        onCreateWindow:
            (InAppWebViewController controller, OnCreateWindowRequest req) {},
        onLoadStart: (InAppWebViewController controller, String url) {
          addClipboardHack(controller);
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
        onConsoleMessage:
            (InAppWebViewController controller, ConsoleMessage consoleMessage) {
          print("Wallet console: " + consoleMessage.message);
        });
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
        "(function() { try {localStorage.setItem('tempKeys', \'{\"privateKey\": \"${keys["privateKey"]}\", \"publicKey\": \"${keys["publicKey"]}\"}\');  localStorage.setItem('state', '$state'); } catch (err) { return err; } })();";

    webView.evaluateJavascript(source: jsToExecute);
    print(jsToExecute);
    var scope = {};
    scope['doubleName'] = await getDoubleName();
    scope['derivedSeed'] = await getDerivedSeed(config.appId());
    var encrypted =
        await encrypt(jsonEncode(scope), keys["publicKey"], privateKey);
    var jsonData = jsonEncode(encrypted);
    var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();

    var loadUrl = //${config.appId()}
        'http://192.168.2.120:8080/${config.redirectUrl()}${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(signedHash)}&data=$data';
    print("LOADURL");
    print(loadUrl);
    webView.loadUrl(url: loadUrl);
  }

  initWallets() async {
    print(await webView.getUrl());
    var jsToExecute = '';
    var importedWallets = await getImportedWallets();
    var appWallets = await getAppWallets();

    if (importedWallets != null) {
      String jsonString = "[" + importedWallets.join(',') + "]";
      jsToExecute += "localStorage.setItem('importedWallets', JSON.stringify(" +
          jsonString +
          "));";
    } else {
      jsToExecute += "localStorage.setItem('importedWallets', null);";
    }

    if (appWallets != null) {
      String jsonString = "[" + appWallets.join(',') + "]";
      jsToExecute += "localStorage.setItem('appWallets', JSON.stringify(" +
          jsonString +
          "));";
    } else {
      jsToExecute += "localStorage.setItem('appWallets', null);";
    }

    this.webView.evaluateJavascript(source: jsToExecute);
  }

  scanQrCode(List<dynamic> params) async {
    dynamic result = await Navigator.pushNamed(context, '/scan');
    return result;
  }

  addHandler() {
    webView.addJavaScriptHandler(
        handlerName: "ADD_IMPORT_WALLET", callback: saveImportedWallet);
    webView.addJavaScriptHandler(
        handlerName: "ADD_APP_WALLET", callback: saveAppWallet);
    webView.addJavaScriptHandler(handlerName: "SCAN_QR", callback: scanQrCode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(child: iaWebView),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
