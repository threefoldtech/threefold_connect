import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';

String openKycApiUrl = AppConfig().openKycApiUrl();
String threeBotApiUrl = AppConfig().threeBotApiUrl();

Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<Response> sendVerificationEmail(String username, String email, String publicKey) async {
  String encodedBody = json.encode({
    'user_id': username,
    'email': email,
    'public_key': publicKey,
  });

  Uri url = Uri.parse('$openKycApiUrl/verification/send-email');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

Future<Response> sendVerificationSms(String username, String phone, String publicKey) async {
  String encodedBody = json.encode({
    'user_id': username,
    'number':  phone,
    'public_key': publicKey,
  });

  Uri url = Uri.parse('$openKycApiUrl/verification/send-sms');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

// https://api.ipgeolocationapi.com/geolocate
Future<String> getCountry() async {
  Uri url = Uri.parse('https://ipinfo.io/country');
  print('Sending call: ${url.toString()}');

  return (await http.get(url)).body.replaceAll("\n", "");
}


Future<Response> getSignedEmailIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {"timestamp": timestamp, "intention": "get-signedemailidentifier"};
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String> loginRequestHeaders = {'Content-type': 'application/json', 'Jimber-Authorization': signedPayload};

  Uri url = Uri.parse('$openKycApiUrl/verification/retrieve-sei/$doubleName');
  print('Sending call: ${url.toString()}');

  return http.get(url, headers: loginRequestHeaders);
}

Future<Response> getSignedPhoneIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {"timestamp": timestamp, "intention": "get-signedphoneidentifier"};
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String> loginRequestHeaders = {'Content-type': 'application/json', 'Jimber-Authorization': signedPayload};

  Uri url = Uri.parse('$openKycApiUrl/verification/retrieve-spi/$doubleName');
  print('Sending call: ${url.toString()}');

  return http.get(url, headers: loginRequestHeaders);
}

Future<Response> verifySignedEmailIdentifierFromOpenKYC(String signedEmailIdentifier) async {
  Uri url = Uri.parse('$openKycApiUrl/verification/verify-sei');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: json.encode({"signedEmailIdentifier": signedEmailIdentifier}), headers: requestHeaders);
}

Future<Response> verifySignedPhoneIdentifierFromOpenKYC(String signedPhoneIdentifier) async {
  Uri url = Uri.parse('$openKycApiUrl/verification/verify-spi');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: json.encode({"signedPhoneIdentifier": signedPhoneIdentifier}), headers: requestHeaders);
}
