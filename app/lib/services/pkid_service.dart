import 'dart:convert';

import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/services/user_service.dart';

Future<void> saveEmailToPKid(FlutterPkid client, Map<String, dynamic> keyPair) async {
  Map<String, Object> email = await getEmail();
  var emailPKidResult = await client.getPKidDoc('email', keyPair);
  if(!emailPKidResult.containsKey('success') && email['email'] != null){
    if(email['sei'] != null) {
      return client.setPKidDoc('email', json.encode({'email': email['email'], 'sei' : email['sei'] }), keyPair);
    }

    if(email['email'] != null){
      return client.setPKidDoc('email', json.encode({'email': email }), keyPair);
    }
  }
}

Future<void> savePhoneToPKid(FlutterPkid client, Map<String, dynamic> keyPair) async {
  Map<String, Object> phone = await getPhone();
  var phonePKidResult = await client.getPKidDoc('phone', keyPair);
  if(!phonePKidResult.containsKey('success') && phone['phone'] != null){
    if(phone['spi'] != null) {
      return client.setPKidDoc('phone', json.encode({'phone': phone['phone'], 'spi' : phone['spi'] }), keyPair);
    }

    if(phone['phone'] != null){
      return client.setPKidDoc('phone', json.encode({'phone': phone }), keyPair);
    }
  }
}