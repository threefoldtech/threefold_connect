import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void copy(List<dynamic> params) {
  Clipboard.setData(new ClipboardData(text: params[0]));
}

Future<String> paste(List<dynamic> params) async {
  return (await Clipboard.getData('text/plain')).text.toString();
}

void addClipboardHack(InAppWebViewController webview) {
  if (Platform.isAndroid) {
    webview.injectJavascriptFileFromAsset(
        assetFilePath: 'assets/clipboardhack.js');
    addClipboardHandlersOnly(webview);
  }
}

void addClipboardHandlersOnly(InAppWebViewController webview) {
  webview.addJavaScriptHandler(handlerName: "COPY", callback: copy);
  webview.addJavaScriptHandler(handlerName: "PASTE", callback: paste);
}
