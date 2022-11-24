import 'dart:convert';
import 'dart:typed_data';

import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';

class Sign {
  String? username;
  String? hashedDataUrl;
  String? dataUrl;
  String? friendlyName;
  String? appId;
  bool? isJson;
  String? type;
  String? randomRoom;
  String? redirectUrl;
  String? state;

  Sign(
      {this.username,
      this.hashedDataUrl,
      this.dataUrl,
      this.friendlyName,
      this.isJson,
      this.appId,
      this.type,
      this.randomRoom,
      this.redirectUrl,
      this.state});

  Sign.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        hashedDataUrl = json['dataUrlHash'],
        dataUrl = json['dataUrl'],
        friendlyName = json['friendlyName'],
        appId = json['appId'],
        isJson = (json['isJson']) == 'true',
        type = json['type'],
        randomRoom = json['randomRoom'],
        redirectUrl = json['redirectUrl'],
        state = json['state'];

  Map<String, dynamic> toJson() => {
        'username': username,
        'hashedDataUrl': hashedDataUrl,
        'dataUrl': dataUrl,
        'friendlyName': friendlyName,
        'isJson': isJson,
        'appId': appId,
        'type': type,
        'randomRoom': randomRoom,
        'redirectUrl': redirectUrl,
        'state': state
      };

  static Future<Sign?> createAndDecryptSignObject(dynamic data) async {
    Sign signData;

    if (data['encryptedSignAttempt'] == null) {
      signData = Sign.fromJson(data);
      return signData;
    }

    Uint8List pk = await getPublicKey();
    Uint8List sk = await getPrivateKey();

    String? decryptedSignAttempt = await decrypt(data['encryptedSignAttempt'], pk, sk);

    if (decryptedSignAttempt == null) {
      print('Signature mismatch for : $data with publicKey ${base64.encode(pk)}');
      return null;
    }

    dynamic decryptedSignAttemptMap = jsonDecode(decryptedSignAttempt);
    print('This is the decrypted sign attempt: $decryptedSignAttempt');

    decryptedSignAttemptMap['type'] = data['type'];
    signData = Sign.fromJson(decryptedSignAttemptMap);

    return signData;
  }
}
