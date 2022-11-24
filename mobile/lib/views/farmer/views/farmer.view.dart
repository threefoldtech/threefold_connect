import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/core/crypto/utils/crypto.utils.dart';
import 'package:threebotlogin/core/router/tabs/views/tabs.views.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/utils/clipboard.utils.dart';
import 'package:threebotlogin/views/farmer/enums/farmer.enums.dart';
import 'package:threebotlogin/views/farmer/options/farmer.options.dart';
import 'package:threebotlogin/views/wallet/configs/wallet.config.dart';

class FarmerScreen extends StatefulWidget {
  FarmerScreen();

  _FarmerScreenState createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> with AutomaticKeepAliveClientMixin {
  late InAppWebViewController webView;
  late InAppWebView iaWebView;

  WalletConfig config = WalletConfig();

  _FarmerScreenState() {
    iaWebView = InAppWebView(
      initialUrlRequest: requestFarmer,
      initialOptions: optionsFarmer,
      onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        print("Farmer console: " + consoleMessage.message);
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        addClipboardHandlersOnly(controller);
      },
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
        this.addHandler();
      },
    );

    Globals().isFarmerCacheCleared = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  _back() async {
    Uri? url = await webView.getUrl();

    if (url.toString() == Globals().farmerUrl + 'farmer') {
      Globals().tabController.animateTo(0);
      return Future.value(true);
    }

    this.webView.goBack();
    return Future.value(true);
  }

  addHandler() {
    webView.addJavaScriptHandler(handlerName: FarmerHandlerTypes.vueInitialized, callback: vueInitialized);
  }

  vueInitialized(List<dynamic> params) async {
    var seed = base64.encode(await getDerivedSeed('wallet.threefold.me'));
    var username = await getUsername();

    var startFarmer = "window.init('$username', '$seed')";

    webView.evaluateJavascript(source: startFarmer);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutDrawer(
        titleText: 'Farming',
        content: WillPopScope(
          child: iaWebView,
          onWillPop: () => _back(),
        ));
  }

  @override
  bool get wantKeepAlive => false;
}
