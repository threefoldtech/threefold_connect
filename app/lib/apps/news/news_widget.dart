import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/apps/news/news_config.dart';
import 'package:threebotlogin/apps/news/news_events.dart';
import 'package:threebotlogin/clipboard_hack/clipboard_hack.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:url_launcher/url_launcher.dart';

bool created = false;

class NewsWidget extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<NewsWidget>
    with AutomaticKeepAliveClientMixin {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  var config = NewsConfig();
  InAppWebView iaWebView;

  _back(NewsBackEvent event) async {
    String url = await webView.getUrl();
    String endsWith = 'news.threefoldconnect.jimber.org/';
    print(url);
    if (url.endsWith(endsWith)) {
      Events().emit(GoHomeEvent());
      return;
    }
    this.webView.goBack();
  }

  _NewsState() {
    iaWebView = InAppWebView(
      initialUrl: 'https://news.threefoldconnect.jimber.org?cache_buster=' +
          new DateTime.now().millisecondsSinceEpoch.toString(),
      initialHeaders: {},
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(debuggingEnabled: true),
          android: AndroidInAppWebViewOptions(
              supportMultipleWindows: true, thirdPartyCookiesEnabled: true),
          ios: IOSInAppWebViewOptions()),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      onCreateWindow:
          (InAppWebViewController controller, CreateWindowRequest req) async {
        await launch(req.url);
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        addClipboardHandlersOnly(controller);
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        setState(() {
          this.progress = progress / 100;
        });
      },
      onConsoleMessage:
          (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        print("News console: " + consoleMessage.message);
      },
    );
    Events().onEvent(NewsBackEvent().runtimeType, _back);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
