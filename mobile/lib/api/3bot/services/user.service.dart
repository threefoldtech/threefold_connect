import 'dart:convert';

import 'package:http/http.dart';
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:http/http.dart' as http;

String threeBotApiUrl = AppConfig().threeBotApiUrl();
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

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
