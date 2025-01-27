import 'dart:convert';

import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/services/migration_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

import 'globals.dart';

Future<void> fetchPKidData() async {
  FlutterPkid client = await getPkidClient();

  List<String> keyWords = ['email', 'phone'];

  var futures = keyWords.map((keyword) async {
    var pKidResult = await client.getPKidDoc(keyword);
    return pKidResult.containsKey('data') && pKidResult.containsKey('success')
        ? jsonDecode(pKidResult['data'])
        : {};
  });

  var pKidResult = await Future.wait(futures);
  Map<int, dynamic> dataMap = pKidResult.asMap();

  await handleKYCData(dataMap[0], dataMap[1]);
}

Future<void> handleKYCData(
    Map<dynamic, dynamic> emailData, Map<dynamic, dynamic> phoneData) async {
  await saveCorrectVerificationStates(emailData, phoneData);
  bool? isEmailVerified = await getIsEmailVerified();
  bool? isPhoneVerified = await getIsPhoneVerified();

  // This method got refactored due my mistake in one little mapping in the migration from no pkid to pkid
  if (isEmailVerified == false) {
    await saveEmailInCorrectFormatPKid(emailData);

    if (phoneData.isNotEmpty) {
      await savePhoneInCorrectFormatPKid(phoneData);
    }
  }

  if (isEmailVerified == true) {
    Globals().emailVerified.value = true;
    await saveEmailInCorrectFormatPKid(emailData);

    if (phoneData.isNotEmpty) {
      await savePhoneInCorrectFormatPKid(phoneData);
    }
  }

  if (isPhoneVerified == true) {
    Globals().phoneVerified.value = true;
    await savePhoneInCorrectFormatPKid(phoneData);
  }
}

bool checkEmail(String email) {
  String? emailValue =
      email.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  return validateEmail(emailValue);
}

String capitalize(String input) {
  if (input.isEmpty) return input;
  return '${input[0].toUpperCase()}${input.substring(1).toLowerCase()}';
}

Future<void> saveCorrectVerificationStates(
    Map<dynamic, dynamic> emailData, Map<dynamic, dynamic> phoneData) async {
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
