import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/core/crypto/utils/crypto.utils.dart';
import 'package:threebotlogin/core/router/tabs/views/tabs.views.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/storage/wallet/wallet.storage.dart';
import 'package:threebotlogin/core/utils/clipboard.utils.dart';
import 'package:threebotlogin/views/wallet/configs/wallet.config.dart';
import 'package:threebotlogin/views/wallet/enums/wallet.enums.dart';
import 'package:threebotlogin/views/wallet/handlers/wallet.handlers.dart';

import '../options/wallet.options.dart';

class WalletScreen extends StatefulWidget {
  WalletScreen();

  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with AutomaticKeepAliveClientMixin {
  late InAppWebViewController webView;
  late InAppWebView iaWebView;

  WalletConfig config = WalletConfig();

  _WalletScreenState() {
    iaWebView = InAppWebView(
      initialUrlRequest: requestWallet,
      initialOptions: optionsWallet,
      onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        print("Wallet console: " + consoleMessage.message);
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        addClipboardHandlersOnly(controller);
      },
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
        this.addHandler();
      },
    );
    Globals().isWalletCacheCleared = true;
  }

  _back() async {
    Uri? url = await webView.getUrl();

    if (url.toString() == Globals().newWalletUrl) {
      Globals().tabController.animateTo(0);
      return Future.value(true);
    }

    this.webView.goBack();
    return Future.value(false);
  }

  addHandler() {
    webView.addJavaScriptHandler(handlerName: WalletHandlerTypes.addImportWallet, callback: saveImportedWallet);
    webView.addJavaScriptHandler(handlerName: WalletHandlerTypes.addAppWallet, callback: saveAppWallet);
    webView.addJavaScriptHandler(handlerName: WalletHandlerTypes.scanQr, callback: scanQrCode);
    webView.addJavaScriptHandler(handlerName: WalletHandlerTypes.vueInitialized, callback: vueInitialized);
    webView.addJavaScriptHandler(handlerName: WalletHandlerTypes.saveWallets, callback: saveWalletCallback);
    webView.addJavaScriptHandler(handlerName: WalletHandlerTypes.signing, callback: signCallback);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutDrawer(
        titleText: 'Wallet',
        content: WillPopScope(
          child: iaWebView,
          onWillPop: () => _back(),
        ));
  }

  vueInitialized(List<dynamic> params) async {
    var seed = base64.encode(await getDerivedSeed('wallet.threefold.me'));
    var username = await getUsername();
    var importedWallets = await getImportedWallets();
    var appWallets = await getAppWallets();

    var startWallet = Globals().useNewWallet == true
        ? "window.init('$username', '$seed')"
        : "window.vueInstance.startWallet('$username', '$seed', '$importedWallets', '$appWallets');";

    webView.evaluateJavascript(source: startWallet);
  }

  @override
  bool get wantKeepAlive => false;
}
