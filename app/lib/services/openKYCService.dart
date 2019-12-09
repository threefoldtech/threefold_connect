import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:threebotlogin/main.dart';
import 'cryptoService.dart';
import 'userService.dart';

String openKycApiUrl = config.openKycApiUrl;
String threeBotApiUrl = config.threeBotApiUrl;
String threeBotFrontEndUrl = config.threeBotFrontEndUrl;

Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future getSignedEmailIdentifierFromOpenKYC(String doubleName) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  String privatekey = await getPrivateKey();

  Map<String, dynamic> payload = {
    "timestamp": timestamp,
    "intention": "get-signedemailidentifier"
  };
  String signedPayload = await signData(jsonEncode(payload), privatekey);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedPayload
  };

  return http.get('$openKycApiUrl/users/$doubleName',
      headers: loginRequestHeaders);
}

Future verifySignedEmailIdentifier(String signedEmailIdentifier) async {
  return http.post('$openKycApiUrl/verify',
      body: json.encode({"signedEmailIdentifier": signedEmailIdentifier}),
      headers: requestHeaders);
}

Future checkVerificationStatus(String doubleName) async {
  return http.get('$openKycApiUrl/users/$doubleName', headers: requestHeaders);
}

Future<http.Response> resendVerificationEmail() async {
  return http.post('$openKycApiUrl/users',
      body: json.encode({
        'user_id': await getDoubleName(),
        'email': (await getEmail())['email'],
        'callback_url': threeBotFrontEndUrl + "verifyemail",
        'public_key': await getPublicKey(),
        'resend': 'true'
      }),
      headers: requestHeaders);
}

Future<http.Response> sendVerificationEmail() async {
  return http.post('$openKycApiUrl/users',
      body: json.encode({
        'user_id': await getDoubleName(),
        'email': (await getEmail())['email'],
        'callback_url': threeBotFrontEndUrl + "verifyemail",
        'public_key': await getPublicKey(),
      }),
      headers: requestHeaders);
}
