import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/helpers/logger.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  void onLoadStart(Uri? url) {
    super.onLoadStart(url);
    logger.i('\n\nStarted $url\n\n');
  }

  @override
  void onLoadStop(Uri? url) {
    super.onLoadStop(url);
    logger.i('\n\nStopped $url\n\n');
  }

  // @override
  // void onLoadError(String url, String code, String message) {
  //   super.onLoadStop(url);
  //   logger.i("\n\nCan't load $url.. Error: $message\n\n");
  // }

  @override
  void onExit() {
    super.onExit();
    logger.w('\n\nBrowser closed!\n\n');
  }
}

MyInAppBrowser inAppBrowser = MyInAppBrowser();
