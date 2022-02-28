import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

String openKycApiUrl = AppConfig().openKycApiUrl();
String threeBotApiUrl = AppConfig().threeBotApiUrl();
String threeBotFrontEndUrl = AppConfig().threeBotFrontEndUrl();

Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<Response> getSignedEmailIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {"timestamp": timestamp, "intention": "get-signedemailidentifier"};
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  Uri url = Uri.parse('$openKycApiUrl/verification/retrieve-sei/$doubleName');
  print('Sending call: ${url.toString()}');

  return http.get(url, headers: loginRequestHeaders);
}

Future<Response> getSignedPhoneIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {"timestamp": timestamp, "intention": "get-signedphoneidentifier"};
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  Uri url = Uri.parse('$openKycApiUrl/verification/retrieve-spi/$doubleName');
  print('Sending call: ${url.toString()}');

  return http.get(url, headers: loginRequestHeaders);
}

Future<Response> getSignedIdentityIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {
    "timestamp": timestamp,
    "intention": "get-identity-kyc-data-identifiers"
  };

  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  Uri url = Uri.parse('$openKycApiUrl/verification/retrieve-sii/$doubleName');
  print('Sending call: ${url.toString()}');

  return http.get(url, headers: loginRequestHeaders);
}

Future<Response> verifySignedEmailIdentifier(String signedEmailIdentifier) async {
  Uri url = Uri.parse('$openKycApiUrl/verification/verify-sei');
  print('Sending call: ${url.toString()}');

  return http.post(url,
      body: json.encode({"signedEmailIdentifier": signedEmailIdentifier}), headers: requestHeaders);
}

Future<Response> verifySignedPhoneIdentifier(String signedPhoneIdentifier) async {
  Uri url = Uri.parse('$openKycApiUrl/verification/verify-spi');
  print('Sending call: ${url.toString()}');

  return http.post(url,
      body: json.encode({"signedPhoneIdentifier": signedPhoneIdentifier}), headers: requestHeaders);
}

Future<Response> verifySignedIdentityIdentifier(
    String signedIdentityNameIdentifier,
    String signedIdentityCountryIdentifier,
    String signedIdentityDOBIdentifier,
    String signedIdentityDocumentMetaIdentifier,
    String signedIdentityGenderIdentifier,
    String reference) async {
  Uri url = Uri.parse('$openKycApiUrl/verification/verify-sii');
  print('Sending call: ${url.toString()}');

  return http.post(url,
      body: json.encode({
        "signedIdentityNameIdentifier": signedIdentityNameIdentifier,
        "signedIdentityCountryIdentifier": signedIdentityCountryIdentifier,
        "signedIdentityDOBIdentifier": signedIdentityDOBIdentifier,
        "signedIdentityDocumentMetaIdentifier": signedIdentityDocumentMetaIdentifier,
        "signedIdentityGenderIdentifier": signedIdentityGenderIdentifier,
        "reference": reference
      }),
      headers: requestHeaders);
}

Future<Response> sendVerificationEmail() async {
  String encodedBody = json.encode({
    'user_id': await getDoubleName(),
    'email': (await getEmail())['email'],
    'public_key': base64.encode(await getPublicKey()),
  });

  Uri url = Uri.parse('$openKycApiUrl/verification/send-email');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

Future<Response> sendVerificationSms() async {
  String encodedBody = json.encode({
    'user_id': await getDoubleName(),
    'number': (await getPhone())['phone'],
    'public_key': base64.encode(await getPublicKey()),
  });

  Uri url = Uri.parse('$openKycApiUrl/verification/send-sms');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

Future<dynamic> getShuftiAccessToken() async {
  Map<String, String?> phoneMap = await getPhone();
  if (phoneMap['spi'] == null) {
    return;
  }

  String encodedBody = json.encode({"signedPhoneIdentifier": phoneMap['spi']});

  Uri url = Uri.parse('$openKycApiUrl/verification/shufti-access-token');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

Future<Response> sendVerificationIdentity() async {
  bool? isPhoneVerified = await getIsPhoneVerified();
  bool? isEmailVerified = await getIsEmailVerified();

  int level = isPhoneVerified == true && isEmailVerified == true ? 2 : 1;

  String encodedBody = json.encode({
    'user_id': await getDoubleName(),
    'kycLevel': (level),
    'public_key': base64.encode(await getPublicKey()),
  });

  Uri url = Uri.parse('$openKycApiUrl/verification/send-identity');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

Future<Response> verifyIdentity(String reference) async {
  print('Verify Identity');
  print('$openKycApiUrl/verification/verify-identity');

  bool? isPhoneVerified = await getIsPhoneVerified();
  bool? isEmailVerified = await getIsEmailVerified();

  int level = isPhoneVerified == true && isEmailVerified == true ? 2 : 1;

  String encodedBody = json.encode({
    'user_id': await getDoubleName(),
    'kycLevel': (level),
    'reference': reference,
  });

  Uri url = Uri.parse('$openKycApiUrl/verification/verify-identity');
  print('Sending call: ${url.toString()}');

  return http.post(url, body: encodedBody, headers: requestHeaders);
}

Future<Response> updateEmailAddressOfUser() async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();

  Map<String, String> payload = {"timestamp": timestamp, "intention": "change-email"};
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String?> email = await getEmail();

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  String encodedBody = jsonEncode({'username': await getDoubleName(), "email": email['email']});

  Uri url = Uri.parse('$threeBotApiUrl/users/change-email');
  print('Sending call: ${url.toString()}');

  return http.post(url, headers: loginRequestHeaders, body: encodedBody);
}
