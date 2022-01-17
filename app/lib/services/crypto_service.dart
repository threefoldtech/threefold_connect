import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:pbkdf2ns/pbkdf2ns.dart';


// Helper method to convert a String input to hex used for entropy
Uint8List _toHex(String input) {
  double length = input.length / 2;
  Uint8List bytes = new Uint8List(length.ceil());

  for (int i = 0; i < bytes.length; i++) {
    String x = input.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(x, radix: 16);
  }

  return bytes;
}

// Generate a random 24 worded seed
Future<String> generateSeedPhrase() async {
  return bip39.generateMnemonic(strength: 256);
}

// Generate a signing keypair from a given seed
Future<KeyPair> generateKeyPairFromSeedPhrase(String seedPhrase) async {
  String entropy = bip39.mnemonicToEntropy(seedPhrase);
  return Sodium.cryptoSignSeedKeypair(_toHex(entropy));
}

// Generate a signing keypair from a given entropy
Future<KeyPair> generateKeyPairFromEntropy(Uint8List entropy) async {
  return Sodium.cryptoSignSeedKeypair(entropy);
}

// Sign given data with the secret signing key
Future<String> signData(String data, Uint8List sk) async {
  Uint8List signed = Sodium.cryptoSign(Uint8List.fromList(data.codeUnits), sk);
  return base64.encode(signed);
}

// Encrypt given data encrypted with a keypair
Future<Map<String, String>> encrypt(String data, Uint8List pk, Uint8List sk) async {
  Uint8List nonce = CryptoBox.randomNonce();
  Uint8List private = Sodium.cryptoSignEd25519SkToCurve25519(sk);
  Uint8List message = Uint8List.fromList(data.codeUnits);
  Uint8List encryptedData = Sodium.cryptoBoxEasy(message, nonce, pk, private);

  return {'nonce': base64.encode(nonce), 'ciphertext': base64.encode(encryptedData)};
}

// Decrypt given ciphertext with a keypair
Future<String> decrypt(String encodedCipherText, Uint8List pk, Uint8List sk) async {
  Uint8List cipherText = base64.decode(encodedCipherText);
  Uint8List publicKey = Sodium.cryptoSignEd25519PkToCurve25519(pk);
  Uint8List secretKey = Sodium.cryptoSignEd25519SkToCurve25519(sk);

  print(base64.encode(publicKey));
  print(base64.encode(secretKey));
  Uint8List decryptedData = Sodium.cryptoBoxSealOpen(cipherText, publicKey, secretKey);
  return new String.fromCharCodes(decryptedData);
}


// Generate a new seed combined with a random salt => appId
Future<Uint8List> generateDerivedSeed(String appId) async {
  Uint8List privateKey = await getPrivateKey();
  String encodedPrivateKey = base64.encode(privateKey);

  PBKDF2NS generator = PBKDF2NS(hash: sha256);
  List<int> hashKey = generator.generateKey(encodedPrivateKey, appId, 1000, 32);

  return new Uint8List.fromList(hashKey);
}