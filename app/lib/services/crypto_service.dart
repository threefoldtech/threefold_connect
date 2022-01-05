import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

Uint8List _toHex(String input) {
  double length = input.length / 2;
  Uint8List bytes = new Uint8List(length.ceil());

  for (int i = 0; i < bytes.length; i++) {
    String x = input.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(x, radix: 16);
  }

  return bytes;
}

Future<String> generateSeedPhrase() async {
  return bip39.generateMnemonic(strength: 256);
}

Future<KeyPair> generateKeyPairFromSeedPhrase(seedPhrase) async {
  String entropy = bip39.mnemonicToEntropy(seedPhrase);
  return Sodium.cryptoSignSeedKeypair(_toHex(entropy));
}

Future<String> generatePublicKeyFromEntropy(encodedEntropy) async {
  Uint8List entropy = base64.decode(encodedEntropy);
  KeyPair keyPair = Sodium.cryptoSignSeedKeypair(entropy);
  return base64.encode(keyPair.pk);
}

Future<String> signData(String data, Uint8List sk) async {
  Uint8List signed = Sodium.cryptoSign(Uint8List.fromList(data.codeUnits), sk);
  return base64.encode(signed);
}

Future<Map<String, String>> encrypt(String data, Uint8List pk, Uint8List sk) async {
  Uint8List nonce = CryptoBox.randomNonce();
  Uint8List private = Sodium.cryptoSignEd25519SkToCurve25519(sk);
  Uint8List message = Uint8List.fromList(data.codeUnits);
  Uint8List encryptedData = Sodium.cryptoBoxEasy(message, nonce, pk, private);

  return {'nonce': base64.encode(nonce), 'cipher': base64.encode(encryptedData)};
}

Future<String> decrypt(String encodedCipherText, Uint8List pk, Uint8List sk) async {
  Uint8List cipherText = base64.decode(encodedCipherText);
  Uint8List publicKey = Sodium.cryptoSignEd25519PkToCurve25519(pk);
  Uint8List secretKey = Sodium.cryptoSignEd25519SkToCurve25519(sk);

  Uint8List decryptedData = Sodium.cryptoBoxSealOpen(cipherText, publicKey, secretKey);
  return new String.fromCharCodes(decryptedData);
}


Future<String> generateDerivedSeed(String appId) async {
  Uint8List privateKey = await getPrivateKey();

  PBKDF2 generator = new PBKDF2();
  List<int> hashKey = generator.generateKey(privateKey, appId, 1000, 32);

  Uint8List derivedSeed = new Uint8List.fromList(hashKey);

  return base64.encode(derivedSeed);
}

Future<Map<String, Object>> generateDerivedKeypair(String appId, String doubleName) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String derivedPublicKey = prefs.getString("${appId.toString()}.dpk");
  String derivedPrivateKey = prefs.getString("${appId.toString()}.dsk");

  String privateKey = await getPrivateKey();

  PBKDF2 generator = new PBKDF2();
  List<int> hashKey = generator.generateKey(privateKey, appId, 1000, 32);

  Map<String, Uint8List> key = await Sodium.cryptoBoxSeedKeypair(new Uint8List.fromList(hashKey));

  if (derivedPublicKey == null || derivedPublicKey == "") {
    derivedPublicKey = base64.encode(key['pk']);
    prefs.setString("${appId.toString()}.dpk", derivedPublicKey);

    Map<String, Object> data = {
      'doubleName': doubleName,
      'signedDerivedPublicKey': await signData(derivedPublicKey, privateKey),
      'signedAppId': await signData(appId, privateKey)
    };

    sendPublicKey(data);
  }

  if (derivedPrivateKey == null || derivedPrivateKey == "") {
    derivedPrivateKey = base64.encode(key['sk']);
    prefs.setString("${appId.toString()}.dsk", derivedPrivateKey);
  }

  return {
    'appId': appId,
    'derivedPublicKey': derivedPublicKey,
    'derivedPrivateKey': derivedPrivateKey
  };
}


void testMe() {
  String base64EncodedEntropy = "tllF+NHT24MLhLVfyCxMbtkoI/wdt+fkQHjELBW78BQ=";

  Uint8List tmp = base64.decode(base64EncodedEntropy);

  Uint8List bytes = new Uint8List.view(tmp.buffer);
  String asHex = hex.encode(bytes);

  String words = bip39.entropyToMnemonic(asHex);
  logger.log(words);
}