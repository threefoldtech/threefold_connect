import 'dart:convert';
import 'dart:typed_data';

import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class Sign {
  String? doubleName;
  String? hashedDataUrl;
  String? dataUrl;
  String? friendlyName;
  String? appId;
  bool? isJson;
  String? type;
  String? randomRoom;
  String? redirectUrl;
  String? state;

  Sign({
    this.doubleName,
    this.hashedDataUrl,
    this.dataUrl,
    this.friendlyName,
    this.isJson,
    this.appId,
    this.type,
    this.randomRoom,
    this.redirectUrl,
    this.state
  });

  Sign.fromJson(Map<String, dynamic> json)
      :
        doubleName = json['doubleName'],
        hashedDataUrl = json['dataUrlHash'],
        dataUrl = json['dataUrl'],
        friendlyName = json['friendlyName'],
        appId = json['appId'],
        isJson = json['isJson'] as bool?,
        type = json['type'],
        randomRoom = json['randomRoom'],
        redirectUrl = json['redirectUrl'],
        state = json['state'];

  Map<String, dynamic> toJson() => {
        'doubleName' : doubleName,
        'hashedDataUrl': hashedDataUrl,
        'dataUrl': dataUrl,
        'friendlyName': friendlyName,
        'isJson': isJson,
        'appId': appId,
        'type' : type,
        'randomRoom' : randomRoom,
        'redirectUrl' : redirectUrl,
        'state' : state
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

      print('This is the signData');
      print(signData);
    } else {
      signData = Sign.fromJson(data);
    }

    return signData;
  }
}
