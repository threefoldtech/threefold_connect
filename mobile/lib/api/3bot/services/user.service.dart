import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';
import 'package:http/http.dart' as http;

String threeBotApiUrl = AppConfig().threeBotApiUrl();
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<bool> updateEmailAddressOfUser() async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  Uint8List sk = await getPrivateKey();
  String username = (await getUsername())!;

  Map<String, String> payload = {"timestamp": timestamp, "intention": "change-email"};
  String signedPayload = await signData(jsonEncode(payload), sk);

  Map<String, String?> email = await getEmail();

  Map<String, String> loginRequestHeaders = {'Content-type': 'application/json', 'Jimber-Authorization': signedPayload};

  String encodedBody = jsonEncode({'username': await getUsername(), "email": email['email']});

  Uri url = Uri.parse('$threeBotApiUrl/users/$username/email');
  print('Sending call: ${url.toString()}');

  Response res = await http.put(url, headers: loginRequestHeaders, body: encodedBody);
  print("updateEmailAddressOfUser with code ${res.statusCode}");

  if (res.statusCode == 200) return true;
  return false;
}

Future<bool> doesUserExistInBackend(String username) async {
  Uri url = Uri.parse('$threeBotApiUrl/users/$username');
  print('Sending call: ${url.toString()}');

  Response res = await http.get(url, headers: requestHeaders);
  print("doesUserExistInBackend with code ${res.statusCode}");

  if (res.statusCode == 404) return false;

  return true;
}

Future<bool> createUser(String username, String email, String publicKey) async {
  Uri url = Uri.parse('$threeBotApiUrl/users');
  print('Sending call: ${url.toString()}');

  Map<String, String> data = {
    'username': username,
    'email': email.toLowerCase().trim(),
    'mainPublicKey': publicKey
  };

  Response res = await http.post(url, body: json.encode(data), headers: requestHeaders);
  print("Created user with code ${res.statusCode}");

  if (res.statusCode != 201) return false;
  return true;
}
