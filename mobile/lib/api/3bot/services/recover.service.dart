import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:threebotlogin/core/config/classes/config.classes.dart';

String threeBotApiUrl = AppConfig().threeBotApiUrl();
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<String?> getUsernameOfPublicKey(String encodedPublicKey) async {
  Uri url = Uri.parse('$threeBotApiUrl/users?publicKey=$encodedPublicKey');
  print('Sending call: ${url.toString()}');

  Response r = await http.get(url);

  if (r.statusCode != 200) {
    print("PublicKey $encodedPublicKey doesn't exist");
    return null;
  }

  Map<String, dynamic> body = jsonDecode(r.body);
  String? username = body['doublename'];

  if (username == null || username.isEmpty) {
    print("Username is not returned");
    return null;
  }

  return username;
}
