import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';

String threeBotApiUrl = AppConfig().threeBotApiUrl();
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<Response> cancelSign() async {
  String? username = await getUsername();

  Uri url = Uri.parse('$threeBotApiUrl/sign/$username/cancel');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: null, headers: requestHeaders);
}

Future<Response> sendSignedData(
    String state, String socketRoom, String signedDataIdentifier, String appId, String dataHash) async {
  Uri url = Uri.parse('$threeBotApiUrl/sign/signed-attempt');
  print('Sending call: ${url.toString()}');

  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();

  Uint8List sk = await getPrivateKey();
  String encodedBody = jsonEncode({
    'signedAttempt': await signData(
        json.encode({
          'signedState': state,
          'signedOn': timestamp,
          'randomRoom': socketRoom,
          'appId': appId,
          'signedData': signedDataIdentifier,
          'doubleName': await getUsername(),
          'dataHash': dataHash
        }),
        sk),
    'doubleName': await getUsername()
  });

  return http.post(url, body: encodedBody, headers: requestHeaders);
}
