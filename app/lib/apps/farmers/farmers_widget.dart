import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/apps/wallet/wallet_events.dart';
import 'package:threebotlogin/apps/wallet/wallet_user_data.dart';
import 'package:threebotlogin/clipboard_hack/clipboard_hack.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet_data.dart';
import 'package:threebotlogin/screens/scan_screen.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

bool created = false;

class FarmersWidget extends StatefulWidget {
  @override
  _FarmersState createState() => _FarmersState();
}

class _FarmersState extends State<FarmersWidget> with AutomaticKeepAliveClientMixin {
  late InAppWebViewController webView;

  double progress = 0;
  var config = WalletConfig();
  late InAppWebView iaWebView;

  _back(WalletBackEvent event) async {
    Uri? url = await webView.getUrl();
    print(url.toString());
    String endsWith = config.appId() + '/';
    if (url.toString().endsWith(endsWith)) {
      Events().emit(GoHomeEvent());
      return;
    }
    this.webView.goBack();
  }

  _FarmersState() {
    String walletUri = Globals().farmersUrl;

    iaWebView = InAppWebView(
      initialUrlRequest: URLRequest(
          url: Uri.parse(
              walletUri + '?cache_buster=' + new DateTime.now().millisecondsSinceEpoch.toString())),
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(),
          android: AndroidInAppWebViewOptions(
              supportMultipleWindows: true, thirdPartyCookiesEnabled: true),
          ios: IOSInAppWebViewOptions()),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
        this.addHandler();
      },
      onCreateWindow: (InAppWebViewController controller, CreateWindowAction req) {
        return Future.value(true);
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        addClipboardHandlersOnly(controller);
        if (url.toString().contains('/init')) {
          initKeys();
        }
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        setState(() {
          this.progress = progress / 100;
        });
      },
      onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        print("Wallet console: " + consoleMessage.message);
      },
    );
    Events().onEvent(WalletBackEvent().runtimeType, _back);
  }

  @override
  void dispose() {
    super.dispose();
  }

  vueInitialized(List<dynamic> params) async {
    initKeys();
  }

  initKeys() async {
    String seed = base64.encode(await getDerivedSeed(config.appId()));
    String? doubleName = await getDoubleName();

    var jsStartApp = "window.init('$doubleName', '$seed')";
    webView.evaluateJavascript(source: jsStartApp);
  }

  Future<String?> scanQrCode(List<dynamic> params) async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    // QRCode scanner is black if we don't sleep here.
    bool slept = await Future.delayed(const Duration(milliseconds: 400), () => true);

    String? result;
    if (slept) {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ScanScreen()));
    }

    return result;
  }

  addHandler() {
    webView.addJavaScriptHandler(handlerName: "ADD_IMPORT_WALLET", callback: saveImportedWallet);
    webView.addJavaScriptHandler(handlerName: "ADD_APP_WALLET", callback: saveAppWallet);
    webView.addJavaScriptHandler(handlerName: "SCAN_QR", callback: scanQrCode);
    webView.addJavaScriptHandler(handlerName: "VUE_INITIALIZED", callback: vueInitialized);
    webView.addJavaScriptHandler(handlerName: "SAVE_WALLETS", callback: saveWalletCallback);
  }

  saveWalletCallback(List<dynamic> params) async {
    try {
      List<WalletData> walletData = [];
      for (var data in params[0]) {
        walletData.add(WalletData(data['name'], data['chain'], data['address']));
      }

      await saveWallets(walletData);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutDrawer(
        titleText: 'Farmers',
        content: Column(
          children: <Widget>[
            Expanded(
              child: Container(child: iaWebView),
            ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => false;
}
