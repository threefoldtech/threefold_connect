import 'dart:convert';
import 'dart:typed_data';

import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/login/classes/scope.classes.dart';

class Login {
  String? username;
  String? state;
  Scope? scope;
  String? appId;
  String? room;
  String? appPublicKey;
  String? randomImageId;
  String? locationId;
  bool? isMobile;
  String? type;
  String? redirectUrl;
  int? created;
  bool? showWarning;

  Login(
      {this.username,
      this.state,
      this.scope,
      this.appId,
      this.appPublicKey,
      this.randomImageId,
      this.room,
      this.isMobile,
      this.type,
      this.redirectUrl,
      this.created,
      this.locationId,
      this.showWarning});

  Login.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        state = json['state'],
        scope = (json['scope'] != null && json['scope'] != "" && json['scope'] != "null")
            ? Scope.fromJson(jsonDecode(json['scope']))
            : null,
        appId = json['appId'],
        appPublicKey = json['appPublicKey'],
        randomImageId = json['randomImageId'],
        room = json['room'],
        isMobile = json['mobile'] as bool?,
        type = json['type'],
        redirectUrl = json['redirectUrl'],
        created = json['created'],
        locationId = json['locationId'],
        showWarning = json['showWarning'] as bool?;

  Map<String, dynamic> toJson() => {
        'username': username,
        'state': state,
        'scope': scope != null ? scope?.toJson() : "",
        'appId': appId,
        'appPublicKey': appPublicKey,
        'randomImageId': randomImageId,
        'room': room,
        'isMobile': isMobile,
        'type': type,
        'redirectUrl': redirectUrl,
        'created': created,
        'showWarning': showWarning,
        'locationId': locationId,
      };

  static Future<Login?> createAndDecryptLoginObject(dynamic data) async {
    Login loginData;

    if (data['encryptedLoginAttempt'] == null) {
      print('Encrypted login attempt is null: $data');
      return null;
    }

    Uint8List pk = await getPublicKey();
    Uint8List sk = await getPrivateKey();

    String? decryptedLoginAttempt = await decrypt(data['encryptedLoginAttempt'], pk, sk);

    if (decryptedLoginAttempt == null) {
      print('Signature mismatch for : $data with publicKey ${base64.encode(pk)}');
      return null;
    }

    dynamic decryptedLoginAttemptMap = jsonDecode(decryptedLoginAttempt);
    print('This is the decrypted login attempt: $decryptedLoginAttempt');

    decryptedLoginAttemptMap['type'] = data['type'];
    decryptedLoginAttemptMap['created'] = data['created'];

    List<dynamic> list = await getLocationIdList();
    decryptedLoginAttemptMap['showWarning'] = !list.contains(decryptedLoginAttemptMap['locationId']);

    loginData = Login.fromJson(decryptedLoginAttemptMap);

    return loginData;
  }
}
