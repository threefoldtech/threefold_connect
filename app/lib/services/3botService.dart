import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:threebotlogin/main.dart';
import 'dart:convert';

import 'package:threebotlogin/screens/ErrorScreen.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/userService.dart';

String threeBotApiUrl = config.threeBotApiUrl;
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

sendScannedFlag(String hash, String deviceId, String doubleName) async {
  http.post(
    '$threeBotApiUrl/flag',
    body: json.encode({'hash': hash, 'deviceId': deviceId, 'isSigned': true, 'doubleName': doubleName}),
    headers: requestHeaders,
  );
}

Future updateDeviceId(String deviceId, String doubleName, String privateKey) async {
  String signedDeviceId = await signData(deviceId, privateKey);

  return http.put('$threeBotApiUrl/users/$doubleName/deviceid',
      body: json.encode({'signedDeviceId': signedDeviceId}),
      headers: requestHeaders);
}

Future sendData(String hash, String signedHash, data, selectedImageId) {
  return http.post('$threeBotApiUrl/sign',
      body: json.encode({
        'hash': hash,
        'signedHash': signedHash,
        'data': data,
        'selectedImageId': selectedImageId
      }),
      headers: requestHeaders);
}

Future sendPublicKey(Map<String, Object> data) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  String privatekey = await getPrivateKey();

  Map<String, dynamic> headers = {
    "timestamp": timestamp,
    "intention": "post-savederivedpublickey"
  };
  String signedHeaders = await signData(jsonEncode(headers), privatekey);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedHeaders
  };

  return http.post('$threeBotApiUrl/savederivedpublickey',
      body: json.encode(data), headers: loginRequestHeaders);
}

Future checkLoginAttempts(String doubleName, {String privateKey = ''}) async {
  if (privateKey == '') {
    privateKey = await getPrivateKey();
  }
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  Map<String, dynamic> payload = {
    "timestamp": timestamp,
    "intention": "attempts"
  };
  String signedPayload = await signData(jsonEncode(payload), privateKey);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  return http.get('$threeBotApiUrl/attempts/$doubleName',
      headers: loginRequestHeaders);
}

Future<Response> removeDeviceId(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  String privatekey = await getPrivateKey();

  Map<String, dynamic> payload = {
    "timestamp": timestamp,
    "intention": "delete-deviceid"
  };
  String signedPayload = await signData(jsonEncode(payload), privatekey);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  try {
    return await http.delete('$threeBotApiUrl/users/$doubleName/deviceid',
      headers: loginRequestHeaders);
  } catch (e) {
    return null;
  }

}

Future<int> checkVersionNumber(BuildContext context, String version) async {
  var minVersion;

  try {
    minVersion =
        (await http.get('$threeBotApiUrl/minversion', headers: requestHeaders))
            .body;
  } on SocketException catch (error) {
    logger.log("Can't connect to server: " + error.toString());
  }

  if (minVersion == null) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ErrorScreen(errorMessage: "Can't connect to server.")));
    return -1;
  } else {
    try {
      int min = int.parse(minVersion);
      int current = int.parse(version);

      if (min <= current) {
        return 1;
      }
    } on Exception catch (e) {
      print(e);
      return 0;
    }
  }

  return 0;
}

Future cancelLogin(doubleName) {
  return http.post('$threeBotApiUrl/users/$doubleName/cancel',
      body: null, headers: requestHeaders);
}

Future getUserInfo(doubleName) {
  return http.get('$threeBotApiUrl/users/$doubleName',
     headers: requestHeaders);
}

Future<http.Response> finishRegistration(String doubleName, String email, String sid, String publicKey) async {
  return http.post('$threeBotApiUrl/mobileregistration', body: json.encode({
    'doubleName' : doubleName+'.3bot',
    'sid' : sid,
    'email' : email,
    'public_key' : publicKey,
  }),
  headers: requestHeaders);
}

Future sendRegisterSign(String doubleName) {
  return http.post('$threeBotApiUrl/signRegister',
      body: json.encode({
        'doubleName': doubleName,
      }),
      headers: requestHeaders);
}

Future<http.Response> getShowApps() async {
    return http.get('$threeBotApiUrl/showapps', headers: requestHeaders);
}