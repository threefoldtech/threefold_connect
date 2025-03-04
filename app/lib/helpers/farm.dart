import 'dart:convert';
import 'dart:typed_data';
import 'package:pinenacl/ed25519.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:convert/convert.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:threebotlogin/services/crypto_service.dart';

Future<Map<String, String>> generateKeypair(String seed) async {
  late final KeyPair keypair;
  late Uint8List bytes;
  final isHex = seed.startsWith('0x');
  if (isHex) {
    final hexString = seed.replaceAll('0x', '');
    bytes = Uint8List.fromList(hex.decode(hexString));
  } else {
    bytes = bip39.mnemonicToSeed(seed).sublist(0, 32);
  }
  keypair = await generateKeyPairFromEntropy(bytes);
  final privateKey = await extractPrivateKey(keypair.secretKey);
  final publicKey = base64.encode(keypair.publicKey);
  return {'privateKey': privateKey, 'publicKey': publicKey};
}

Future<String> extractPrivateKey(SecureKey secureKey) async {
  return await secureKey.runUnlockedAsync((keyData) {
    return base64.encode(keyData);
  });
}
