import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

String cacheBusterFarmer = new DateTime.now().millisecondsSinceEpoch.toString();

URLRequest requestFarmer = URLRequest(url: Uri.parse(Globals().farmerUrl + '?cache_buster=' + cacheBusterFarmer));

InAppWebViewGroupOptions optionsFarmer = InAppWebViewGroupOptions(
    crossPlatform: Globals().enableCacheFarmer
        ? InAppWebViewOptions()
        : InAppWebViewOptions(
            cacheEnabled: Globals().isFarmerCacheCleared, clearCache: !Globals().isFarmerCacheCleared),
    android: AndroidInAppWebViewOptions(supportMultipleWindows: true, useHybridComposition: true));
