import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

String cacheBuster = new DateTime.now().millisecondsSinceEpoch.toString();

bool useNewWallet = Globals().useNewWallet;
String walletUrl = Globals().useNewWallet ? Globals().newWalletUrl : Globals().oldWalletUrl;

URLRequest requestWallet = URLRequest(url: Uri.parse(walletUrl + '?cache_buster=' + cacheBuster));

InAppWebViewGroupOptions optionsWallet = InAppWebViewGroupOptions(
    crossPlatform: Globals().enableCacheWallet
        ? InAppWebViewOptions()
        : InAppWebViewOptions(
            cacheEnabled: Globals().isWalletCacheCleared, clearCache: !Globals().isWalletCacheCleared),
    android: AndroidInAppWebViewOptions(supportMultipleWindows: true, useHybridComposition: true));
