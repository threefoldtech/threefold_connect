import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:validators/validators.dart';

const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

String randomString(int len) {
  Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
  String result = '';

  for (int i = 0; i < len; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }

  return result;
}

bool validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return false;
  }

  return isEmail(value);
}

bool validateSeedWords(String seed, String confirmationWords) {
  List<String> words = confirmationWords.split(' ');
  List<String> seedWords = seed.split(' ');

  // if length is not correct return already here
  if (words.length != 3) return false;

  for (final String word in words) {
    // check every word in list against the seed
    if (!seedWords.contains(word)) {
      return false;
    }
  }
  return true;
}

bool validateDoubleName(String value) {
  return isAlphanumeric(value) && isLength(value, 4);
}

String extract3Bot(String name) {
  return name.replaceAll('.3bot', '');
}

bool isJson(String str) {
  try {
    jsonDecode(str);
  } catch (e) {
    return false;
  }
  return true;
}

Future<String> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  String info = '';
  if (Platform.isIOS) {
    IosDeviceInfo i = await deviceInfoPlugin.iosInfo;
    info = 'IOS_${i.systemVersion.toString()}';
  } else if (Platform.isAndroid) {
    AndroidDeviceInfo i = await deviceInfoPlugin.androidInfo;
    info =
        'ANDROID_${i.brand.toString().replaceAll(" ", "").toUpperCase()}_${i.model.toString().replaceAll(" ", "").toUpperCase()}_SDK${i.version.sdkInt}';
  }

  return info;
}

extension BoolParsing on String {
  bool parseBool() {
    return toLowerCase() == 'true';
  }
}
