import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

String cacheBuster = new DateTime.now().millisecondsSinceEpoch.toString();

URLRequest request = URLRequest(url: Uri.parse(Globals().newsUrl + '?cache_buster=' + cacheBuster));

InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    android: AndroidInAppWebViewOptions(supportMultipleWindows: true, useHybridComposition: true));
