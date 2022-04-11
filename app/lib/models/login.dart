import 'dart:convert';
import 'dart:typed_data';

import 'package:threebotlogin/models/scope.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class Login {
  String? doubleName;
  String? state;
  Scope? scope;
  String? appId;
  String? appPublicKey;
  String? randomImageId;
  String? type;
  String? randomRoom;
  String? redirectUrl;
  bool? isMobile;
  int? created;
  String? locationId;
  bool? showWarning;

  Login(
      {this.doubleName,
      this.state,
      this.scope,
      this.appId,
      this.appPublicKey,
      this.randomImageId,
      this.type,
      this.randomRoom,
      this.redirectUrl,
      this.isMobile,
      this.created,
      this.locationId});

  Login.fromJson(Map<String, dynamic> json)
      : doubleName = json['doubleName'],
        state = json['state'],
        scope = (json['scope'] != null && json['scope'] != "" && json['scope'] != "null")
            ? Scope.fromJson(jsonDecode(json['scope']))
            : null,
        appId = json['appId'],
        appPublicKey = json['appPublicKey'],
        randomImageId = json['randomImageId'],
        type = json['type'],
        randomRoom = json['randomRoom'],
        redirectUrl = json['redirecturl'],
        isMobile = json['mobile'] as bool?,
        created = json['created'],
        locationId = json['locationId'];

  Map<String, dynamic> toJson() => {
        'doubleName': doubleName,
        'state': state,
        'scope': scope != null ? scope?.toJson() : "",
        'appId': appId,
        'appPublicKey': appPublicKey,
        'randomImageId': randomImageId,
        'type': type,
        'randomRoom': randomRoom,
        'redirecturl': redirectUrl,
        'mobile': isMobile,
        'created': created,
        'locationId': locationId
      };

  static Future<Login> createAndDecryptLoginObject(dynamic data) async {
    Login loginData;

    if (data['encryptedLoginAttempt'] != null) {
      Uint8List pk = await getPublicKey();
      Uint8List sk = await getPrivateKey();

      String decryptedLoginAttempt = await decrypt(data['encryptedLoginAttempt'], pk, sk);
      dynamic decryptedLoginAttemptMap = jsonDecode(decryptedLoginAttempt);

      print('Decrypted login attempt');
      print(decryptedLoginAttempt);

      decryptedLoginAttemptMap['type'] = data['type'];
      decryptedLoginAttemptMap['created'] = data['created'];

      loginData = Login.fromJson(decryptedLoginAttemptMap);
    } else {
      loginData = Login.fromJson(data);
    }

    loginData.isMobile = false;

    List<dynamic> list = await getLocationIdList();

    loginData.showWarning = !list.contains(loginData.locationId);
    return loginData;
  }
}
