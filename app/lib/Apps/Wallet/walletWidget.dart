import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/Apps/Wallet/walletUserData.dart';
import 'package:threebotlogin/ClipboardHack/ClipboardHack.dart';
import 'package:threebotlogin/screens/ScanScreen.dart';
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
        initialUrl:  'http://192.168.2.229:8080/init', //https://${config.appId()}/init',
        initialHeaders: {},
        initialOptions: InAppWebViewWidgetOptions(
            crossPlatform: InAppWebViewOptions(debuggingEnabled: true),
            android: AndroidInAppWebViewOptions(
                supportMultipleWindows: true, thirdPartyCookiesEnabled: true)),
        onWebViewCreated: (InAppWebViewController controller) {
          webView = controller;
          this.addHandler();
        },
        onCreateWindow:
            (InAppWebViewController controller, OnCreateWindowRequest req) {},
        onLoadStart: (InAppWebViewController controller, String url) {
          addClipboardHack(controller);

        },
        onLoadStop: (InAppWebViewController controller, String url) async {
          if (url.contains('/init')) {
            initKeys();
            initWallets();
          }
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
    var seed = await getDerivedSeed(config.appId());
    var doubleName = await getDoubleName();
    var jsStartApp = "window.vueInstance.startWallet('$doubleName', '$seed');";

    webView.evaluateJavascript(source: jsStartApp);
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
    dynamic result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ScanScreen()));
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
