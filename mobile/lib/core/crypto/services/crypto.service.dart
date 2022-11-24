import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:threebotlogin/core/crypto/utils/transform.utils.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:pbkdf2ns/pbkdf2ns.dart';
import 'package:crypto/crypto.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

KeyPair generateKeyPairFromMnemonic(String mnemonic) {
  String entropy = bip39.mnemonicToEntropy(mnemonic);
  return Sodium.cryptoSignSeedKeypair(toHex(entropy));
}

Future<String> signData(String data, Uint8List sk) async {
  Uint8List signed = Sodium.cryptoSign(Uint8List.fromList(data.codeUnits), sk);
  return base64.encode(signed);
}

Future<String?> decrypt(String encodedCipherText, Uint8List pk, Uint8List sk) async {
  Uint8List cipherText = base64.decode(encodedCipherText);
  Uint8List publicKey = Sodium.cryptoSignEd25519PkToCurve25519(pk);
  Uint8List secretKey = Sodium.cryptoSignEd25519SkToCurve25519(sk);

  try {
    Uint8List decryptedData = Sodium.cryptoBoxSealOpen(cipherText, publicKey, secretKey);
    return new String.fromCharCodes(decryptedData);
  } catch (e) {
    return null;
  }
}

Future<KeyPair> generateKeyPairFromEntropy(Uint8List entropy) async {
  return Sodium.cryptoSignSeedKeypair(entropy);
}

Future<Uint8List> generateDerivedSeed(String appId) async {
  Uint8List privateKey = await getPrivateKey();
  String encodedPrivateKey = base64.encode(privateKey);

  PBKDF2NS generator = PBKDF2NS(hash: sha256);
  List<int> hashKey = generator.generateKey(encodedPrivateKey, appId, 1000, 32);

  return new Uint8List.fromList(hashKey);
}

Future<Map<String, String>> encrypt(String data, Uint8List pk, Uint8List sk) async {
  Uint8List nonce = CryptoBox.randomNonce();
  Uint8List private = Sodium.cryptoSignEd25519SkToCurve25519(sk);
  Uint8List message = Uint8List.fromList(data.codeUnits);
  Uint8List encryptedData = Sodium.cryptoBoxEasy(message, nonce, pk, private);

  return {'nonce': base64.encode(nonce), 'ciphertext': base64.encode(encryptedData)};
}

String hashData(String data) {
  final List<int> codeUnits = data.codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);

  return base64.encode(Sodium.cryptoHash(unit8List));
}

Future<String> hashDataFromUrl(String url) async {
  Uri uri = Uri.parse(url);
  Response r = await http.get(uri);
  return hashData((json.encode(json.decode(r.body))));
}
