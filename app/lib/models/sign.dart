import 'dart:convert';
import 'dart:typed_data';

import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class Sign {
  String? doubleName;
  String? hashedDataUrl;
  String? dataUrl;
  String? appId;
  bool? isJson;
  String? type;
  String? randomRoom;

  Sign({
    this.doubleName,
    this.hashedDataUrl,
    this.dataUrl,
    this.isJson,
    this.appId,
    this.type,
    this.randomRoom
  });

  Sign.fromJson(Map<String, dynamic> json)
      :
        doubleName = json['doubleName'],
        hashedDataUrl = json['dataUrlHash'],
        dataUrl = json['dataUrl'],
        appId = json['appId'],
        isJson = json['isJson'] as bool?,
        type = json['type'],
        randomRoom = json['randomRoom'];

  Map<String, dynamic> toJson() => {
        'doubleName' : doubleName,
        'hashedDataUrl': hashedDataUrl,
        'dataUrl': dataUrl,
        'isJson': isJson,
        'appId': appId,
        'type' : type,
        'randomRoom' : randomRoom
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
