import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/core/router/tabs/views/tabs.views.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/utils/clipboard.utils.dart';
import 'package:threebotlogin/views/support/options/support.options.dart';

class SupportScreen extends StatefulWidget {
  SupportScreen();

  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with AutomaticKeepAliveClientMixin {
  late InAppWebViewController webView;
  late InAppWebView iaWebView;

  _SupportScreenState() {
    iaWebView = InAppWebView(
      initialUrlRequest: requestSupport,
      initialOptions: optionsSupport,
      onLoadStop: (InAppWebViewController controller, _) {
        controller.evaluateJavascript(source: hideButtonInjections);
        addClipboardHandlersOnly(controller);
      },
      onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        print("Support console: " + consoleMessage.message);
      },
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
    );

    Globals().isFarmerCacheCleared = true;
  }

  _back() async {
    Uri? url = await webView.getUrl();

    if (url.toString() == Globals().supportUrl) {
      Globals().tabController.animateTo(0);
      return Future.value(true);
    }

    this.webView.goBack();
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutDrawer(
        titleText: 'Support',
        content: WillPopScope(
          child: iaWebView,
          onWillPop: () => _back(),
        ));
  }

  @override
  bool get wantKeepAlive => false;
}
