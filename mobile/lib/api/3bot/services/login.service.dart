import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';

String threeBotApiUrl = AppConfig().threeBotApiUrl();
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<Response> cancelLogin() async {
  String? username = await getUsername();

  Uri url = Uri.parse('$threeBotApiUrl/login/$username/cancel');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: null, headers: requestHeaders);
}

Future<Response> sendData(String state, Map<String, String>? data, selectedImageId, String? room, String appId) async {
  String username = (await getUsername())!;
  Uri url = Uri.parse('$threeBotApiUrl/login/$username');
  print('Sending call: ${url.toString()}');

  String encodedBody = json.encode({
    'signedAttempt': await signData(
        json.encode({
          'doubleName': username,
          'signedState': state,
          'data': data,
          'room': room,
          'appId': appId,
          'selectedImageId': selectedImageId,
        }),
        await getPrivateKey()),
    'doubleName': await getUsername()

  });

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

Future<Response> addDigitalTwinDerivedPublicKeyToBackend(String publicKey, String appId) async {
  String username = (await getUsername())!;

  Uri url = Uri.parse('$threeBotApiUrl/digitaltwin');
  print('Sending call: ${url.toString()}');

  Uint8List sk = await getPrivateKey();
  String encodedData = json.encode({'derivedPublicKey': publicKey, 'appId': appId});
  String signedData = await signData(encodedData, sk);

  Map<String, String> body = {'username': username, 'signedData': signedData};

  return http.post(url, body: json.encode(body), headers: requestHeaders);
}
