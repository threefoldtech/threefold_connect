import 'dart:convert';

import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/user_service.dart';

import 'globals.dart';

Future<void> fetchPKidData() async {
  Map<String, dynamic> keyPair = await generateKeyPairFromSeedPhrase(await getPhrase());
  var client = FlutterPkid(pkidUrl, keyPair);

  List<String> keyWords = ['email', 'phone', 'identity'];

  var futures = keyWords.map((keyword) async {
    var pKidResult = await client.getPKidDoc(keyword, keyPair);
    return pKidResult.containsKey('data') && pKidResult.containsKey('success') ? jsonDecode(pKidResult['data']) : {};
  });

  var pKidResult = await Future.wait(futures);
  Map<int, Object> dataMap = pKidResult.asMap();

  await handleKYCData(dataMap[0], dataMap[1], dataMap[2]);
}

Future<void> handleKYCData(
    Map<dynamic, dynamic> emailData, Map<dynamic, dynamic> phoneData, Map<dynamic, dynamic> identityData) async {
  await saveCorrectVerificationStates(emailData, phoneData, identityData);

  bool isEmailVerified = await getIsEmailVerified();
  bool isPhoneVerified = await getIsPhoneVerified();
  bool isIdentityVerified = await getIsIdentityVerified();

  if (isEmailVerified == false) {

    // This is needed cause a small mapping mistake in a previous migration to PKID
    try {
      if (emailData['email']['email'] != null) {
        await saveEmail(emailData['email']['email'], null);
      }
    } catch (e) {
      await saveEmail(emailData['email'], null);
    }



    if (phoneData.isNotEmpty) {
      if (phoneData['phone'] != null) {
        await savePhone(phoneData['phone'], null);
      }
    }
  }

  if (isEmailVerified == true) {
    Globals().emailVerified.value = true;
    await saveEmail(emailData['email'], emailData['sei']);

    if (phoneData.isNotEmpty) {
      await savePhone(phoneData['phone'], null);
    }
  }

  if (isPhoneVerified == true) {
    Globals().phoneVerified.value = true;
    await savePhone(phoneData['phone'], phoneData['spi']);
  }

  if (isIdentityVerified == true) {
    Globals().identityVerified.value = true;
    await saveIdentity(
        jsonDecode(identityData['identityName']),
        identityData['signedIdentityNameIdentifier'],
        identityData['identityCountry'],
        identityData['signedIdentityCountryIdentifier'],
        identityData['identityDOB'],
        identityData['signedIdentityDOBIdentifier'],
        jsonDecode(identityData['identityDocumentMeta']),
        identityData['signedIdentityDocumentMetaIdentifier'],
        identityData['identityGender'],
        identityData['signedIdentityGenderIdentifier']);
  }
}

Future<void> saveCorrectVerificationStates(
    Map<dynamic, dynamic> emailData, Map<dynamic, dynamic> phoneData, Map<dynamic, dynamic> identityData) async {
  if (identityData.containsKey('signedIdentityNameIdentifier')) {
    await setIsIdentityVerified(true);
  } else {
    await setIsIdentityVerified(false);
  }

  if (phoneData.containsKey('spi')) {
    await setIsPhoneVerified(true);
  } else {
    await setIsPhoneVerified(false);
  }

  if (emailData.containsKey('sei')) {
    await setIsEmailVerified(true);
  } else {
    await setIsEmailVerified(false);
  }
}

bool checkEmail(String email) {
  String emailValue = email.toLowerCase()?.trim()?.replaceAll(new RegExp(r"\s+"), " ");
  return validateEmail(emailValue);
}
