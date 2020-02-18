import 'dart:convert';
import 'dart:typed_data';

import 'package:threebotlogin/models/scope.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/user_service.dart';

class Login {
  String doubleName;
  String state;
  Scope scope;
  String appId;
  String appPublicKey;
  String randomImageId;
  String type;
  String randomRoom;
  String redirecturl;
  bool isMobile;
  int created;
  String locationId;
  bool showWarning;

  Login(
      {this.doubleName,
      this.state,
      this.scope,
      this.appId,
      this.appPublicKey,
      this.randomImageId,
      this.type,
      this.randomRoom,
      this.redirecturl,
      this.isMobile,
      this.created,
      this.locationId});

  Login.fromJson(Map<String, dynamic> json)
      : doubleName = json['doubleName'],
        state = json['state'],
        scope = (json['scope'] != null && json['scope'] != "" && json['scope'] != "null") ? Scope.fromJson(jsonDecode(json['scope'])) : null,
        appId = json['appId'],
        appPublicKey = json['appPublicKey'],
        randomImageId = json['randomImageId'],
        type = json['type'],
        randomRoom = json['randomRoom'],
        redirecturl = json['redirecturl'],
        isMobile = json['mobile'] as bool,
        created = json['created'],
        locationId = json['locationId'];

  Map<String, dynamic> toJson() => {
        'doubleName': doubleName,
        'state': state,
        'scope': scope != null ? scope.toJson() : "",
        'appId': appId,
        'appPublicKey': appPublicKey,
        'randomImageId': randomImageId,
        'type': type,
        'randomRoom': randomRoom,
        'redirecturl': redirecturl,
        'mobile': isMobile,
        'created': created,
        'locationId': locationId
      };

    static Future<Login> createAndDecryptLoginObject(dynamic data) async {
      Login loginData;

      if(data['encryptedLoginAttempt'] != null) {
        Uint8List decryptedLoginAttempt = await decrypt(data['encryptedLoginAttempt'], await getPublicKey(), await getPrivateKey());
        data['encryptedLoginAttempt'] = new String.fromCharCodes(decryptedLoginAttempt);

        var decryptedLoginAttemptMap = jsonDecode(data['encryptedLoginAttempt']);

        decryptedLoginAttemptMap['type'] = data['type'];
        decryptedLoginAttemptMap['created'] = data['created'];

        loginData = Login.fromJson(decryptedLoginAttemptMap);
      } else {
        loginData = Login.fromJson(data);
      }
      
      loginData.isMobile = false;

      List<dynamic> list = await getLocationIdList();

      if(list.contains(loginData.locationId)) {
        loginData.showWarning = false;
      } else {
        loginData.showWarning = true;
      }

      return loginData;
    }

}
