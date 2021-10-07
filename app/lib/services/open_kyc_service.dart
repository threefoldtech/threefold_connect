import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/user_service.dart';

String openKycApiUrl = AppConfig().openKycApiUrl();
String threeBotApiUrl = AppConfig().threeBotApiUrl();
String threeBotFrontEndUrl = AppConfig().threeBotFrontEndUrl();

Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<Response> getSignedEmailIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  String privatekey = await getPrivateKey();

  Map<String, String> payload = {"timestamp": timestamp, "intention": "get-signedemailidentifier"};
  String signedPayload = await signData(jsonEncode(payload), privatekey);

  Map<String, String> loginRequestHeaders = {'Content-type': 'application/json', 'Jimber-Authorization': signedPayload};

  return http.get('$openKycApiUrl/verification/retrieve-sei/$doubleName', headers: loginRequestHeaders);
}

Future<Response> getSignedPhoneIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  String privatekey = await getPrivateKey();

  Map<String, String> payload = {"timestamp": timestamp, "intention": "get-signedphoneidentifier"};
  String signedPayload = await signData(jsonEncode(payload), privatekey);

  Map<String, String> loginRequestHeaders = {'Content-type': 'application/json', 'Jimber-Authorization': signedPayload};

  return http.get('$openKycApiUrl/verification/retrieve-spi/$doubleName', headers: loginRequestHeaders);
}

Future<Response> getSignedIdentityIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  String privateKey = await getPrivateKey();

  Map<String, String> payload = {"timestamp": timestamp, "intention": "get-identity-kyc-data-identifiers"};

  String signedPayload = await signData(jsonEncode(payload), privateKey);

  Map<String, String> loginRequestHeaders = {'Content-type': 'application/json', 'Jimber-Authorization': signedPayload};

  return http.get('$openKycApiUrl/verification/retrieve-sii/$doubleName', headers: loginRequestHeaders);
}

Future<Response> verifySignedEmailIdentifier(String signedEmailIdentifier) async {
  return http.post('$openKycApiUrl/verification/verify-sei',
      body: json.encode({"signedEmailIdentifier": signedEmailIdentifier}), headers: requestHeaders);
}

Future<Response> verifySignedPhoneIdentifier(String signedPhoneIdentifier) async {
  return http.post('$openKycApiUrl/verification/verify-spi',
      body: json.encode({"signedPhoneIdentifier": signedPhoneIdentifier}), headers: requestHeaders);
}

Future<Response> verifySignedIdentityIdentifier(
    String signedIdentityNameIdentifier,
    String signedIdentityCountryIdentifier,
    String signedIdentityDOBIdentifier,
    String signedIdentityDocumentMetaIdentifier,
    String signedIdentityGenderIdentifier,
    String reference) async {
  return http.post('$openKycApiUrl/verification/verify-sii',
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
  print('$openKycApiUrl/verification/send-email');
  return http.post('$openKycApiUrl/verification/send-email',
      body: json.encode({
        'user_id': await getDoubleName(),
        'email': (await getEmail())['email'],
        'public_key': await getPublicKey(),
      }),
      headers: requestHeaders);
}

Future<Response> sendVerificationSms() async {
  print('sms send');
  return http.post('$openKycApiUrl/verification/send-sms',
      body: json.encode({
        'user_id': await getDoubleName(),
        'number': (await getPhone())['phone'],
        'public_key': await getPublicKey(),
      }),
      headers: requestHeaders);
}

Future<dynamic> getShuftiAccessToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  dynamic signedPhoneIdentifier = prefs.getString('signedPhoneIdentifier');

  if (signedPhoneIdentifier == null) {
    return;
  }

  print('Getting shufti Access token');
  print('$openKycApiUrl/verification/shufti-access-token');
  return http.post('$openKycApiUrl/verification/shufti-access-token',
      body: json.encode({"signedPhoneIdentifier": signedPhoneIdentifier}),
      headers: requestHeaders);
}

Future<Response> sendVerificationIdentity() async {
  print('Sending verification identity');
  print('$openKycApiUrl/verification/send-identity');
  return http.post('$openKycApiUrl/verification/send-identity',
      body: json.encode({
        'user_id': await getDoubleName(),
        'kycLevel': (await getKYCLevel()),
        'public_key': await getPublicKey(),
      }),
      headers: requestHeaders);
}

Future<Response> verifyIdentity(String reference) async {
  print('Verify Identity');
  print('$openKycApiUrl/verification/verify-identity');
  return http.post('$openKycApiUrl/verification/verify-identity',
      body: json.encode({
        'user_id': await getDoubleName(),
        'kycLevel': json.encode(await getKYCLevel()),
        'reference': reference,
      }),
      headers: requestHeaders);
}
