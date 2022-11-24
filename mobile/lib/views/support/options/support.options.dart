import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

String cacheBusterSupport = new DateTime.now().millisecondsSinceEpoch.toString();

URLRequest requestSupport = URLRequest(url: Uri.parse(Globals().supportUrl + '?cache_buster=' + cacheBusterSupport));

InAppWebViewGroupOptions optionsSupport = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true),
    android: AndroidInAppWebViewOptions(supportMultipleWindows: true, useHybridComposition: true));

String hideButtonInjections = """
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
        """;
