import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void copy(List<dynamic> params) {
  Clipboard.setData(new ClipboardData(text: params[0]));
}

Future<String?> paste(List<dynamic> params) async {
  ClipboardData? data = await Clipboard.getData('text/plain');
  return data?.text.toString();
}

void addClipboardHandlersOnly(InAppWebViewController wv) {
  wv.addJavaScriptHandler(handlerName: "COPY", callback: copy);
  wv.addJavaScriptHandler(handlerName: "PASTE", callback: paste);
}
