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

Future<Map<String, String>> generateKeyPair() async {
  Map<String, Uint8List> keys = await Sodium.cryptoBoxKeypair();

  return {
    'privateKey': base64.encode(keys['sk']),
    'publicKey': base64.encode(keys['pk'])
  };
}

Uint8List _toHex(String input) {
  double length = input.length / 2;
  Uint8List bytes = new Uint8List(length.ceil());

  for (int i = 0; i < bytes.length; i++) {
    String x = input.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(x, radix: 16);
  }

  return bytes;
}

Future<Map<String, String>> generateKeysFromSeedPhrase(seedPhrase) async {
  String entropy = bip39.mnemonicToEntropy(seedPhrase);
  Map<String, Uint8List> key =
      await Sodium.cryptoSignSeedKeypair(_toHex(entropy));

  return {
    'publicKey': base64.encode(key['pk']).toString(),
    'privateKey': base64.encode(key['sk']).toString()
  };
}

Future<String> generatePublicKeyFromEntropy(encodedEntropy) async {
  Uint8List entropy = base64.decode(encodedEntropy);
  Map<String, Uint8List> key = await Sodium.cryptoSignSeedKeypair(entropy);

  return base64.encode(key['pk']).toString();
}

Future<String> signData(String data, String sk) async {
  Uint8List private = base64.decode(sk);
  Uint8List signed =
      await Sodium.cryptoSign(Uint8List.fromList(data.codeUnits), private);

  return base64.encode(signed);
}

Future<Map<String, String>> encrypt(
    String data, String publicKey, String sk) async {
  Uint8List nonce = await CryptoBox.generateNonce();
  Uint8List private =
      await Sodium.cryptoSignEd25519SkToCurve25519(base64.decode(sk));
  Uint8List public = base64.decode(publicKey);
  Uint8List message = Uint8List.fromList(data.codeUnits);
  Uint8List encryptedData =
      await Sodium.cryptoBoxEasy(message, nonce, public, private);

  return {
    'nonce': base64.encode(nonce),
    'ciphertext': base64.encode(encryptedData)
  };
}

Future<Uint8List> decrypt(String encodedCipherText, String encodedPublicKey,
    String encodedSecretKey) async {
  Uint8List cipherText = base64.decode(encodedCipherText);
  Uint8List publicKey = await Sodium.cryptoSignEd25519PkToCurve25519(
      base64.decode(encodedPublicKey));
  Uint8List secretKey = await Sodium.cryptoSignEd25519SkToCurve25519(
      base64.decode(encodedSecretKey));

  return await Sodium.cryptoBoxSealOpen(cipherText, publicKey, secretKey);
}

Future<String> generateSeedPhrase() async {
  return bip39.generateMnemonic(strength: 256);
}

void testMe() {
  String base64EncodedEntropy = "tllF+NHT24MLhLVfyCxMbtkoI/wdt+fkQHjELBW78BQ=";

  Uint8List tmp = base64.decode(base64EncodedEntropy);

  Uint8List bytes = new Uint8List.view(tmp.buffer);
  String asHex = hex.encode(bytes);

  String words = bip39.entropyToMnemonic(asHex);
  logger.log(words);
}

Future<String> generateDerivedSeed(String appId) async {
  String privateKey = await getPrivateKey();

  PBKDF2 generator = new PBKDF2();
  List<int> hashKey = generator.generateKey(privateKey, appId, 1000, 32);

  Uint8List derivedSeed = new Uint8List.fromList(hashKey);

  return base64.encode(derivedSeed);
}

Future<Map<String, Object>> generateDerivedKeypair(
    String appId, String doubleName) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String derivedPublicKey = prefs.getString("${appId.toString()}.dpk");
  String derivedPrivateKey = prefs.getString("${appId.toString()}.dsk");

  String privateKey = await getPrivateKey();

  PBKDF2 generator = new PBKDF2();
  List<int> hashKey = generator.generateKey(privateKey, appId, 1000, 32);

  Map<String, Uint8List> key =
      await Sodium.cryptoBoxSeedKeypair(new Uint8List.fromList(hashKey));

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
