import 'dart:convert';

import 'package:threebotlogin/models/scope.dart';

class Login {
  String doubleName;
  String state;
  Scope scope;
  String appId;
  String appPublicKey;
  String randomImageId;
  String type;
  String loginId;
  String signedRoom;
  String redirecturl;
  bool isMobile;
  int created;

  Login(
      {this.doubleName,
      this.state,
      this.scope,
      this.appId,
      this.appPublicKey,
      this.randomImageId,
      this.type,
      this.loginId,
      this.signedRoom,
      this.redirecturl,
      this.isMobile,
      this.created});

  Login.fromJson(Map<String, dynamic> json)
      : doubleName = json['doubleName'],
        state = json['state'],
        scope = (json['scope'] != null && json['scope'] != "" && json['scope'] != "null") ? Scope.fromJson(jsonDecode(json['scope'])) : null,
        appId = json['appId'],
        appPublicKey = json['appPublicKey'],
        randomImageId = json['randomImageId'],
        type = json['type'],
        loginId = json['loginId'],
        signedRoom = json['signedRoom'],
        redirecturl = json['redirecturl'],
        isMobile = json['mobile'] as bool,
        created = json['created'];

  Map<String, dynamic> toJson() => {
        'doubleName': doubleName,
        'state': state,
        'scope': scope != null ? scope.toJson() : "",
        'appId': appId,
        'appPublicKey': appPublicKey,
        'randomImageId': randomImageId,
        'type': type,
        'loginId': loginId,
        'signedRoom': signedRoom,
        'redirecturl': redirecturl,
        'mobile': isMobile,
        'created': created,
      };
}
