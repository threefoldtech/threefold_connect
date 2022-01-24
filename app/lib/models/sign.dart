import 'dart:convert';
import 'dart:typed_data';

import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class Sign {
  String? hashedDataUrl;
  String? dataUrl;
  String? appId;
  bool? isJson;

  Sign({
    this.hashedDataUrl,
    this.dataUrl,
    this.isJson,
    this.appId,
  });

  Sign.fromJson(Map<String, dynamic> json)
      : hashedDataUrl = json['dataUrlHash'],
        dataUrl = json['dataUrl'],
        appId = json['appId'],
        isJson = json['isJson'] as bool?;

  Map<String, dynamic> toJson() => {
        'hashedDataUrl': hashedDataUrl,
        'dataUrl': dataUrl,
        'isJson': isJson,
        'appId': appId,
      };

  static Future<Sign> createAndDecryptSignObject(dynamic data) async {
    Sign signData;

    if (data['encryptedSignAttempt'] != null) {
      Uint8List pk = await getPublicKey();
      Uint8List sk = await getPrivateKey();

      String encryptedSignAttempt = await decrypt(data['encryptedSignAttempt'], pk, sk);
      dynamic decryptedSignAttemptMap = jsonDecode(encryptedSignAttempt);

      print('Decrypted login attempt');
      print(decryptedSignAttemptMap);

      decryptedSignAttemptMap['type'] = data['type'];
      signData = Sign.fromJson(decryptedSignAttemptMap);
    } else {
      signData = Sign.fromJson(data);
    }

    return signData;
  }
}
