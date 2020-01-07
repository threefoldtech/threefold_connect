import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/Apps/Wallet/walletEvents.dart';
import 'package:threebotlogin/Apps/Wallet/walletUserData.dart';
import 'package:threebotlogin/ClipboardHack/ClipboardHack.dart';
import 'package:threebotlogin/Events/Events.dart';
import 'package:threebotlogin/Events/GoHomeEvent.dart';
import 'package:threebotlogin/screens/ScanScreen.dart';
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

  _back(WalletBackEvent event) async {
    String url = await webView.getUrl();
    String endsWith = config.appId() + '/';
    if (url.endsWith(endsWith)) {
      Events().emit(GoHomeEvent());
      return;
    }
    this.webView.goBack();
  }

  _WalletState() {
    iaWebView = InAppWebView(
        initialUrl: 'http://${config.appId()}/init',
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
    Events().onEvent(WalletBackEvent().runtimeType, _back);
  }

  @override
  void dispose() {
    super.dispose();
  }

  initKeys() async {
    var seed = await getDerivedSeed(config.appId());
    var doubleName = await getDoubleName();
    var importedWallets = await getImportedWallets();
    var appWallets = await getAppWallets();

    var jsStartApp = "window.vueInstance.startWallet('$doubleName', '$seed', '$importedWallets', '$appWallets');";

    webView.evaluateJavascript(source: jsStartApp);
  }

  scanQrCode(List<dynamic> params) async {
    String result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ScanScreen()));
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
  bool get wantKeepAlive => true;
}
