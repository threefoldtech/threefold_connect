import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

String threeBotApiUrl = AppConfig().threeBotApiUrl();
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<bool> isAppUpToDate() async {
  Uri url = Uri.parse('$threeBotApiUrl/minimumversion');
  print('Sending call: ${url.toString()}');

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  int currentBuildNumber = int.parse(packageInfo.buildNumber);
  int minimumBuildNumber = 0;

  String jsonResponse =
      (await http.get(url, headers: requestHeaders).timeout(Duration(seconds: Globals().httpTimeout))).body;

  Map<String, dynamic> minimumVersion = json.decode(jsonResponse);

  if (Platform.isAndroid) {
    minimumBuildNumber = minimumVersion['android'];
  } else if (Platform.isIOS) {
    minimumBuildNumber = minimumVersion['ios'];
  }

  return currentBuildNumber >= minimumBuildNumber;
}

Future<bool> isAppUnderMaintenance() async {
  Uri url = Uri.parse('$threeBotApiUrl/maintenance');
  print('Sending call: ${url.toString()}');

  Response r = await http.get(url, headers: requestHeaders).timeout(Duration(seconds: Globals().httpTimeout));

  if (r.statusCode != 200) {
    print('isAppUnderMaintenance failed with statusCode ${r.statusCode}');
    return false;
  }

  Map<String, dynamic> mappedResponse = json.decode(r.body);
  return mappedResponse['maintenance'] == 1;
}

Future<bool> checkIfPkidIsAvailable() async {
  Uri url = Uri.parse(AppConfig().pKidUrl());
  print('Sending call: ${url.toString()}');

  Response r = await http.get(url, headers: requestHeaders).timeout(Duration(seconds: Globals().httpTimeout));

  if (r.statusCode != 200 && r.statusCode != 404) {
    print('checkIfPkidIsAvailable failed with statusCode ${r.statusCode}');
    return false;
  }

  return true;
}
