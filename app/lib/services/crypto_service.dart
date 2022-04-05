import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:pbkdf2ns/pbkdf2ns.dart';


bool verifyHash(String data, String hash) {
  final List<int> codeUnits = data.codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);

  Uint8List hashedData = Sodium.cryptoHash(unit8List);

  return hash == base64.encode(hashedData);
}

String hashData(String data) {
  final List<int> codeUnits = data.codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);

  return base64.encode(Sodium.cryptoHash(unit8List));
}


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

// Verify signed data
bool verifySignature(Uint8List signedMessage, Uint8List pk) {
  try {
    Uint8List data = Sodium.cryptoSignOpen(signedMessage, pk);
    print(utf8.decode(data));
    return true;
  }
  catch(e) {
    print(e);
    return false;
  }
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