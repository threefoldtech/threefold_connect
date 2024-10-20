import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:bip39/bip39.dart' as bip39;
import 'package:sodium_libs/sodium_libs.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:pbkdf2ns/pbkdf2ns.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/tweetnacl.dart' show TweetNaClExt;

Future<bool> verifyHash(String data, String hash) async {
  final List<int> codeUnits = data.codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);

  Sodium sodium = await SodiumInit.init();
  Uint8List hashedData = sodium.crypto.genericHash.call(message: unit8List);

  return hash == base64.encode(hashedData);
}

Future<String> hashData(String data) async {
  final List<int> codeUnits = data.codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);

  Sodium sodium = await SodiumInit.init();
  return base64.encode(sodium.crypto.genericHash.call(message: unit8List));
}

// Helper method to convert a String input to hex used for entropy
Uint8List _toHex(String input) {
  double length = input.length / 2;
  Uint8List bytes = Uint8List(length.ceil());

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
  Sodium sodium = await SodiumInit.init();
  String entropy = bip39.mnemonicToEntropy(seedPhrase);

  return sodium.crypto.sign.seedKeyPair(sodium.secureCopy(_toHex(entropy)));
}

// Generate a signing keypair from a given entropy
Future<KeyPair> generateKeyPairFromEntropy(Uint8List entropy) async {
  Sodium sodium = await SodiumInit.init();
  return sodium.crypto.sign.seedKeyPair(sodium.secureCopy(entropy));
}

// Sign given data with the secret signing key
Future<String> signData(String data, Uint8List sk) async {
  Sodium sodium = await SodiumInit.init();
  Uint8List signed = sodium.crypto.sign.call(
      message: Uint8List.fromList(data.codeUnits),
      secretKey: sodium.secureCopy(sk));
  return base64.encode(signed);
}

// Verify signed data
Future<bool> verifySignature(Uint8List signedMessage, Uint8List pk) async {
  try {
    Sodium sodium = await SodiumInit.init();
    Uint8List data =
        sodium.crypto.sign.open(signedMessage: signedMessage, publicKey: pk);

    print(utf8.decode(data));
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

// Encrypt given data encrypted with a keypair
Future<Map<String, String>> encrypt(
    String data, Uint8List pk, Uint8List sk) async {
  Sodium sodium = await SodiumInit.init();
  Uint8List nonce = sodium.randombytes.buf(24);

  final secretKey = Uint8List(32);
  TweetNaClExt.crypto_sign_ed25519_sk_to_x25519_sk(secretKey, sk);

  Uint8List message = Uint8List.fromList(data.codeUnits);
  Uint8List encryptedData = sodium.crypto.box.easy(
      message: message,
      nonce: nonce,
      publicKey: pk,
      secretKey: sodium.secureCopy(secretKey));

  return {
    'nonce': base64.encode(nonce),
    'ciphertext': base64.encode(encryptedData)
  };
}

// Decrypt given ciphertext with a keypair
Future<String> decrypt(
    String encodedCipherText, Uint8List pk, Uint8List sk) async {
  Uint8List cipherText = base64.decode(encodedCipherText);
  Sodium sodium = await SodiumInit.init();

  final publicKey = Uint8List(32);
  TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(publicKey, pk);

  final secretKey = Uint8List(32);
  TweetNaClExt.crypto_sign_ed25519_sk_to_x25519_sk(secretKey, sk);

  Uint8List decryptedData = sodium.crypto.box.sealOpen(
      cipherText: cipherText,
      publicKey: publicKey,
      secretKey: sodium.secureCopy(secretKey));
  return String.fromCharCodes(decryptedData);
}

// Generate a seed combined with a random salt => appId
Future<Uint8List> generateDerivedSeed(String appId) async {
  Uint8List privateKey = await getPrivateKey();
  String encodedPrivateKey = base64.encode(privateKey);

  PBKDF2NS generator = PBKDF2NS(hash: sha256);
  List<int> hashKey = generator.generateKey(encodedPrivateKey, appId, 1000, 32);

  return Uint8List.fromList(hashKey);
}
