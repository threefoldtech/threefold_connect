import 'dart:async';

import 'package:flutter/services.dart';

class Redirection {
  static const MethodChannel _channel = MethodChannel('redirection');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> redirect() async {
    String response = await _channel.invokeMethod('redirect');
    return response == '1';
  }
}
