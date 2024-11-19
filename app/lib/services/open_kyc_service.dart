import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

String openKycApiUrl = AppConfig().openKycApiUrl();
String threeBotApiUrl = AppConfig().threeBotApiUrl();
String threeBotFrontEndUrl = AppConfig().threeBotFrontEndUrl();

Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<Response> getSignedEmailIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {
    'timestamp': timestamp,
    'intention': 'get-signedemailidentifier'
  };
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  Uri url = Uri.parse('$openKycApiUrl/verification/retrieve-sei/$doubleName');
  logger.i('Sending call: ${url.toString()}');

  return http.get(url, headers: loginRequestHeaders);
}

Future<Response> getSignedPhoneIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {
    'timestamp': timestamp,
    'intention': 'get-signedphoneidentifier'
  };
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  Uri url = Uri.parse('$openKycApiUrl/verification/retrieve-spi/$doubleName');
  logger.i('Sending call: ${url.toString()}');

  return http.get(url, headers: loginRequestHeaders);
}

Future<Response> verifySignedEmailIdentifier(
    String signedEmailIdentifier) async {
  Uri url = Uri.parse('$openKycApiUrl/verification/verify-sei');
  logger.i('Sending call: ${url.toString()}');

  return http.post(url,
      body: json.encode({'signedEmailIdentifier': signedEmailIdentifier}),
      headers: requestHeaders);
}

Future<Response> verifySignedPhoneIdentifier(
    String signedPhoneIdentifier) async {
  Uri url = Uri.parse('$openKycApiUrl/verification/verify-spi');
  logger.i('Sending call: ${url.toString()}');

  return http.post(url,
      body: json.encode({'signedPhoneIdentifier': signedPhoneIdentifier}),
      headers: requestHeaders);
}

Future<Response> sendVerificationEmail() async {
  String encodedBody = json.encode({
    'user_id': await getDoubleName(),
    'email': (await getEmail())['email'],
    'public_key': base64.encode(await getPublicKey()),
  });

  Uri url = Uri.parse('$openKycApiUrl/verification/send-email');
  logger.i('Sending call: ${url.toString()}');

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

Future<Response> sendVerificationSms() async {
  String encodedBody = json.encode({
    'user_id': await getDoubleName(),
    'number': (await getPhone())['phone'],
    'public_key': base64.encode(await getPublicKey()),
  });

  Uri url = Uri.parse('$openKycApiUrl/verification/send-sms');
  logger.i('Sending call: ${url.toString()}');

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

// TODO: Remove this method and use update user data
Future<Response> updateEmailAddressOfUser() async {
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {
    'timestamp': timestamp,
    'intention': 'change-email'
  };
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String?> email = await getEmail();

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  String encodedBody = jsonEncode({
    'username': await getDoubleName(),
    'field': 'email',
    'value': email['email']
  });

  Uri url = Uri.parse('$threeBotApiUrl/users/update');
  logger.i('Sending call: ${url.toString()}');

  return http.post(url, headers: loginRequestHeaders, body: encodedBody);
}

Future<Response> updateUserData(String field, String value) async {
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {
    'timestamp': timestamp,
    'intention': 'change-$field'
  };
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  String encodedBody = jsonEncode(
      {'username': await getDoubleName(), 'field': field, 'value': value});

  Uri url = Uri.parse('$threeBotApiUrl/users/update');
  logger.i('Sending call: ${url.toString()}');

  return http.post(url, headers: loginRequestHeaders, body: encodedBody);
}

Future<Response> deleteUser() async {
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {
    'timestamp': timestamp,
    'intention': 'delete-user'
  };
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  final doubleName = await getDoubleName();
  Uri url = Uri.parse('$threeBotApiUrl/users/$doubleName');
  logger.i('Sending call: ${url.toString()}');

  return http.delete(url, headers: loginRequestHeaders);
}
