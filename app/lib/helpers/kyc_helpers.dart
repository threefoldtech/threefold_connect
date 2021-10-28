import 'dart:convert';

import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/user_service.dart';

import 'globals.dart';

Future<void> handleKYCData(
    Map<dynamic, dynamic> emailData, Map<dynamic, dynamic> phoneData, Map<dynamic, dynamic> identityData) async {
  int kycLevel = calculateKYCLevel(emailData, phoneData, identityData);
  await saveKYCLevel(kycLevel);

  if (kycLevel == 0) {
    await saveEmail(emailData['email'], null);
  }

  if (kycLevel >= 1) {
    Globals().emailVerified.value = true;
    await saveEmail(emailData['email'], emailData['sei']);

    if (phoneData.isNotEmpty) {
      await savePhone(phoneData['phone'], null);
    }
  }

  if (kycLevel >= 2) {
    Globals().phoneVerified.value = true;
    await savePhone(phoneData['phone'], phoneData['spi']);
  }

  if (kycLevel == 3) {
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

int calculateKYCLevel(
    Map<dynamic, dynamic> emailData, Map<dynamic, dynamic> phoneData, Map<dynamic, dynamic> identityData) {
  if (identityData.containsKey('signedIdentityNameIdentifier')) {
    return 3;
  }

  if (phoneData.containsKey('spi') && !identityData.containsKey('signedIdentityNameIdentifier')) {
    return 2;
  }

  if (emailData.containsKey('sei') && !phoneData.containsKey('spi')) {
    return 1;
  }

  if (!emailData.containsKey('sei')) {
    return 0;
  }

  return -1;
}

Future<void> saveCorrectKYCLevel() async {
  await saveKYCLevel(0);

  if(Globals().emailVerified.value == true) {
    await saveKYCLevel(1);
  }

  if(Globals().phoneVerified.value == true) {
    await saveKYCLevel(2);
  }

  if(Globals().identityVerified.value == true) {
    await saveKYCLevel(3);
  }
}

bool checkEmail(String email) {
  String emailValue = email.toLowerCase()?.trim()?.replaceAll(new RegExp(r"\s+"), " ");
  return validateEmail(emailValue);
}