import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/Apps/Chatbot/ChatbotConfig.dart';
import 'package:threebotlogin/services/userService.dart';


class ChatbotWidget extends StatefulWidget {
  @override
  _ChatbotState createState() => new _ChatbotState();
}

class _ChatbotState extends State<ChatbotWidget>
    with AutomaticKeepAliveClientMixin {
  InAppWebViewController webView;

  ChatbotConfig config = ChatbotConfig();
  InAppWebView iaWebview;

  _ChatbotState() {
    init();
  }
  init() async {
    var email = await getEmail();
    iaWebview = InAppWebView(
      initialUrl: '${config.url()}${email['email']}',
      initialHeaders: {},
      initialOptions: InAppWebViewWidgetOptions(
          android: AndroidInAppWebViewOptions(supportMultipleWindows: true)),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      onCreateWindow:
          (InAppWebViewController controller, OnCreateWindowRequest req) {
        print("Create!");
        //browser.open(url: req.url, options: InAppBrowserClassOptions());
      },
      onLoadStart: (InAppWebViewController controller, String url) {},
      onLoadStop: (InAppWebViewController controller, String url) async {},
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
