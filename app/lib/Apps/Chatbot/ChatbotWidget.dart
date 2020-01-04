import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/Apps/Chatbot/ChatbotConfig.dart';
import 'package:threebotlogin/Browser.dart';
import 'package:threebotlogin/ClipboardHack/ClipboardHack.dart';

class ChatbotWidget extends StatefulWidget {
  final String email;

  ChatbotWidget({this.email});
  @override
  _ChatbotState createState() => new _ChatbotState(email: this.email);
}

class _ChatbotState extends State<ChatbotWidget>
    with AutomaticKeepAliveClientMixin {
  InAppWebViewController webView;

  ChatbotConfig config = ChatbotConfig();
  InAppWebView iaWebview;
  final String email;

  _ChatbotState({this.email}) {
    iaWebview = InAppWebView(
      initialUrl: '${config.url()}$email',
      initialHeaders: {},
      initialOptions: InAppWebViewWidgetOptions( crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true),
          android: AndroidInAppWebViewOptions( supportMultipleWindows: true)),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      onCreateWindow:
          (InAppWebViewController controller, OnCreateWindowRequest req) {
        inAppBrowser.open(url: req.url, options: InAppBrowserClassOptions());
      },
      onConsoleMessage:
          (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        print("CB console: " + consoleMessage.message);
      },
      onLoadStart: (InAppWebViewController controller, String url) {},
      onLoadStop: (InAppWebViewController controller, String url) async {
       addClipboardHack(controller);
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {},
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(child: iaWebview),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
