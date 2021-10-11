import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:convert/convert.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:password_hash/password_hash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/user_service.dart';

import 'crypto_service.dart';

String pKidUrl = AppConfig().pKidUrl();

Uint8List _toHex(String input) {
  double length = input.length / 2;
  Uint8List bytes = new Uint8List(length.ceil());

  for (int i = 0; i < bytes.length; i++) {
    String x = input.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(x, radix: 16);
  }

  return bytes;
}

Future<Response> getPKidDoc(String key) async {
  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  String seedPhrase = await getPhrase();
  Map<String, String> keyPair = await generateKeysFromSeedPhrase(seedPhrase);

  return http.get('$pKidUrl/documents/${hex.encode(base64.decode(keyPair['publicKey']))}/$key', headers: requestHeaders);
}


Future<Response> setPKidDoc(String key, String payload) async {
  int timestamp = new DateTime.now().millisecondsSinceEpoch;
  Map<String, dynamic> requestHeaders = {'intent': 'pkid.store', 'timestamp': timestamp};

  String seedPhrase = await getPhrase();

  Map<String, String> keyPair = await generateKeysFromSeedPhrase(seedPhrase);
  String handledPayload = await encryptPKid(payload, keyPair['publicKey']);

  Map<String, dynamic> payloadContainer = {'is_encrypted': 1, 'payload': handledPayload, 'data_version': 1};

  print(await signEncode(jsonEncode(payloadContainer), keyPair['privateKey']));

  try {
    return await http.put('$pKidUrl/documents/${hex.encode(base64.decode(keyPair['publicKey']))}/$key',
        body: json.encode(await signEncode(jsonEncode(payloadContainer), keyPair['privateKey'])),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': await signEncode(jsonEncode(requestHeaders), keyPair['privateKey'])
        });
  } catch (e) {
    print('Error');
    print(e);
    return http.Response('Error in setPKidDoc' , 500);
  }
}

Future<String> encryptPKid(String json, String bobPublicKey) async {
  Uint8List message = utf8.encode(json);
  Uint8List publicKey = await Sodium.cryptoSignEd25519PkToCurve25519(base64.decode(bobPublicKey));
  Uint8List encryptedData = await Sodium.cryptoBoxSeal(message, publicKey);
  return base64.encode(encryptedData);
}

Future<String> decryptPKid(String cipherText, String bobPublicKey, String bobSecretKey) async {
  Uint8List cipherEncodedText = base64.decode(cipherText);

  Uint8List publicKey = await Sodium.cryptoSignEd25519PkToCurve25519(base64.decode(bobPublicKey));
  Uint8List secretKey = await Sodium.cryptoSignEd25519SkToCurve25519(base64.decode(bobSecretKey));

  Uint8List decrypted = await Sodium.cryptoBoxSealOpen(cipherEncodedText, publicKey, secretKey);

  if (decrypted == null) {
    return null;
  }

  String base64DecryptedMessage = new String.fromCharCodes(decrypted);
  return base64DecryptedMessage;
}

Future<Uint8List> sign(String message, String privateKey) async {
  Uint8List decodedPrivateKey = base64.decode(privateKey);
  return await Sodium.cryptoSign(Uint8List.fromList(message.codeUnits), decodedPrivateKey);
}

Future<String> signEncode(String payload, String secretKey) async {
  return base64Encode(await sign(payload, secretKey));
}

Uint8List toHex(String input) {
  double length = input.length / 2;
  Uint8List bytes = new Uint8List(length.ceil());

  for (int i = 0; i < bytes.length; i++) {
    String x = input.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(x, radix: 16);
  }

  return bytes;
}

Future<Map<String, String>> generateKeyPair() async {
  Map<String, Uint8List> keys = await Sodium.cryptoBoxKeypair();
  return {'privateKey': base64.encode(keys['sk']), 'publicKey': base64.encode(keys['pk'])};
}
