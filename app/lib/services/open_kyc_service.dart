import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
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

  Map<String, String> payload = {
    "timestamp": timestamp,
    "intention": "get-signedemailidentifier"
  };
  String signedPayload = await signData(jsonEncode(payload), privatekey);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  return http.get('$openKycApiUrl/verification/retrieve-sei/$doubleName',
      headers: loginRequestHeaders);
}

Future<Response> verifySignedEmailIdentifier(
    String signedEmailIdentifier) async {
  return http.post('$openKycApiUrl/verification/verify-sei',
      body: json.encode({"signedEmailIdentifier": signedEmailIdentifier}),
      headers: requestHeaders);
}

Future<Response> sendVerificationEmail() async {
  return http.post('$openKycApiUrl/verification/send-email',
      body: json.encode({
        'user_id': await getDoubleName(),
        'email': (await getEmail())['email'],
        'public_key': await getPublicKey(),
      }),
      headers: requestHeaders);
}
