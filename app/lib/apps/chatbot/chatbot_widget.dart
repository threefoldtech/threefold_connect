import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/apps/chatbot/chatbot_config.dart';
import 'package:threebotlogin/browser.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class ChatbotWidget extends StatefulWidget {
  final String email;

  ChatbotWidget({required this.email});

  @override
  _ChatbotState createState() => new _ChatbotState(email: this.email);
}

class _ChatbotState extends State<ChatbotWidget> with AutomaticKeepAliveClientMixin {
  InAppWebViewController? webView;

  ChatbotConfig config = ChatbotConfig();
  InAppWebView? iaWebview;
  final String email;

  _ChatbotState({required this.email}) {
    iaWebview = InAppWebView(
      initialUrlRequest: URLRequest(
          url: Uri.parse('${config.url()}$email&cache_buster=' +
              new DateTime.now().millisecondsSinceEpoch.toString())),
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true),
          android: AndroidInAppWebViewOptions(supportMultipleWindows: true, useHybridComposition: true)),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      onCreateWindow: (InAppWebViewController controller, CreateWindowAction req) {
        inAppBrowser.openUrlRequest(urlRequest: req.request, options: InAppBrowserClassOptions());
        return Future.value(true);
      },
      onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        print("CB console: " + consoleMessage.message);
      },
      onLoadStart: (InAppWebViewController controller, _) {
        webView = controller;
      },
      onLoadStop: (InAppWebViewController controller, _) {
        controller.evaluateJavascript(source: """
          function waitForElm(selector) {
          return new Promise(resolve => {
              if (document.querySelector(selector)) {
                  return resolve(document.querySelector(selector));
              }
      
              const observer = new MutationObserver(mutations => {
                  if (document.querySelector(selector)) {
                      resolve(document.querySelector(selector));
                      observer.disconnect();
                  }
              });
      
              observer.observe(document.body, {
                  childList: true,
                  subtree: true
              });
          });
      }
      
      waitForElm('.cc-4xbu').then(elm => document.querySelector(`.cc-4xbu`).style.cssText = 'display: none !important' )
        """);
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
    super.build(context);
    return LayoutDrawer(
        titleText: 'Support',
        content: Column(
          children: <Widget>[
            Expanded(
              child: Container(child: iaWebview),
            ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
