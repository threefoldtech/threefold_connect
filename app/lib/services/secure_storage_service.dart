import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> savePrivateKey(Uint8List privateKey) async {
    await _storage.write(
      key: 'privatekey',
      value: base64.encode(privateKey),
    );
  }

  static Future<Uint8List?> getPrivateKey() async {
    final encoded = await _storage.read(key: 'privatekey');
    return encoded != null ? base64.decode(encoded) : null;
  }

  static Future<void> savePin(String pin) async {
    await _storage.write(key: 'pin', value: pin);
  }

  static Future<String?> getPin() async {
    return await _storage.read(key: 'pin');
  }

  static Future<void> savePhrase(String phrase) async {
    await _storage.write(key: 'phrase', value: phrase);
  }

  static Future<String?> getPhrase() async {
    return await _storage.read(key: 'phrase');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
