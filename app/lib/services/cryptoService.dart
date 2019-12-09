import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:password_hash/password_hash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/userService.dart';

Future<Map<String, String>> generateKeyPair() async {
  var keys = await Sodium.cryptoBoxKeypair();

  return {
    'privateKey': base64.encode(keys['sk']),
    'publicKey': base64.encode(keys['pk'])
  };
}

Uint8List toHex(String input) {
  double length = input.length / 2;
  Uint8List bytes = new Uint8List(length.ceil());

  for (var i = 0; i < bytes.length; i++) {
    var x = input.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(x, radix: 16);
  }

  return bytes;
}

Future<Map<String, String>> generateKeysFromSeedPhrase(seedPhrase) async {
  String entropy = bip39.mnemonicToEntropy(seedPhrase);
  Map<String, Uint8List> key =
      await Sodium.cryptoSignSeedKeypair(toHex(entropy));

  return {
    'publicKey': base64.encode(key['pk']).toString(),
    'privateKey': base64.encode(key['sk']).toString()
  };
}

Future<String> signData(String data, String sk) async {
  var private = base64.decode(sk);
  var signed =
      await Sodium.cryptoSign(Uint8List.fromList(data.codeUnits), private);

  return base64.encode(signed);
}

Future<bool> verifySign(String data, String pk) async {
  var sig = base64.decode(data);
  var h = hex.encode(sig);
  var valid = await CryptoSign.verify(sig, h, base64.decode(pk));

  return valid;
}

Future<Map<String, String>> encrypt(
    String data, String publicKey, String sk) async {
  var nonce = await CryptoBox.generateNonce();
  var private = await Sodium.cryptoSignEd25519SkToCurve25519(base64.decode(sk));
  var public = base64.decode(publicKey);
  var message = Uint8List.fromList(data.codeUnits);
  var encryptedData =
      await Sodium.cryptoBoxEasy(message, nonce, public, private);

  return {
    'nonce': base64.encode(nonce),
    'ciphertext': base64.encode(encryptedData)
  };
}

Future<String> generateSeedPhrase() async {
  return bip39.generateMnemonic(strength: 256);
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
  final prefs = await SharedPreferences.getInstance();

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

    var data = {
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
