import 'dart:convert';

import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

import '../app_config.dart';
import 'crypto_service.dart';

Future<FlutterPkid> getPkidClient({String seedPhrase = ''}) async {
  String pKidUrl = AppConfig().pKidUrl();

  String? phrase = seedPhrase != '' ? seedPhrase : await getPhrase();
  KeyPair keyPair = await generateKeyPairFromSeedPhrase(phrase!);

  return FlutterPkid(pKidUrl, keyPair);
}

Future<void> saveEmailToPKidForMigration() async {
  FlutterPkid client = await getPkidClient();

  Map<String, String?> email = await getEmail();
  var emailPKidResult = await client.getPKidDoc('email');

  if (!emailPKidResult.containsKey('success') && email['email'] != null) {
    if (email['sei'] != null) {
      await client.setPKidDoc('email', json.encode({'email': email['email'], 'sei': email['sei']}));
      return;
    }

    if (email['email'] != null) {
      await client.setPKidDoc('email', json.encode({'email': email['email']}));
      return;
    }
  }
}

Future<void> savePhoneToPKidForMigration() async {
  FlutterPkid client = await getPkidClient();

  Map<String, String?> phone = await getPhone();
  var phonePKidResult = await client.getPKidDoc('phone');

  if (!phonePKidResult.containsKey('success') && phone['phone'] != null) {
    if (phone['spi'] != null) {
      await client.setPKidDoc('phone', json.encode({'phone': phone['phone'], 'spi': phone['spi']}));
      return;
    }

    if (phone['phone'] != null) {
      await client.setPKidDoc('phone', json.encode({'phone': phone}));
      return;
    }
  }
}

Future<void> saveEmailToPKid() async {
  FlutterPkid client = await getPkidClient();

  Map<String, String?> email = await getEmail();

  if (email['sei'] != null) {
    await client.setPKidDoc('email', json.encode({'email': email['email'], 'sei': email['sei']}));
    return;
  }

  if (email['email'] != null) {
    await client.setPKidDoc('email', json.encode({'email': email['email']}));
    return;
  }
}

Future<void> savePhoneToPKid() async {
  FlutterPkid client = await getPkidClient();

  Map<String, String?> phone = await getPhone();

  if (phone['spi'] != null) {
    await client.setPKidDoc('phone', json.encode({'phone': phone['phone'], 'spi': phone['spi']}));
    return;
  }

  if (phone['phone'] != null) {
    await client.setPKidDoc('phone', json.encode({'phone': phone['phone']}));
    return;
  }
}

Future<dynamic> getEmailFromPKid() async {
  FlutterPkid client = await getPkidClient();
  return await client.getPKidDoc('email');
}

Future<dynamic> getPhoneFromPkid() async {
  FlutterPkid client = await getPkidClient();
  return await client.getPKidDoc('phone');
}
