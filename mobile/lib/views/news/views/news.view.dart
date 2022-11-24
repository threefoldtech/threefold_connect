import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/core/router/tabs/views/tabs.views.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/utils/clipboard.utils.dart';
import 'package:threebotlogin/views/news/options/news.options.dart';

class NewsScreen extends StatefulWidget {
  NewsScreen();

  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with AutomaticKeepAliveClientMixin {
  late InAppWebViewController webView;
  late InAppWebView iaWebView;

  _NewsScreenState() {
    iaWebView = InAppWebView(
      initialUrlRequest: request,
      initialOptions: options,
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        addClipboardHandlersOnly(controller);
      },
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
    );
  }

  _back() async {
    Uri? url = await webView.getUrl();

    if (url.toString().endsWith(cacheBuster)) {
      Globals().tabController.animateTo(0);
      return Future.value(true);
    }

    this.webView.goBack();
    return Future.value(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutDrawer(
        titleText: 'News',
        content: WillPopScope(
          child: iaWebView,
          onWillPop: () => _back(),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
