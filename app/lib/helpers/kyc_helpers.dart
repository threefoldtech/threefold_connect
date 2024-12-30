import 'dart:convert';

import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/models/idenfy.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/idenfy_service.dart';
import 'package:threebotlogin/services/migration_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';

import 'globals.dart';

Future<void> fetchPKidData() async {
  FlutterPkid client = await getPkidClient();

  List<String> keyWords = ['email', 'phone'];
  final wallets = (await getPkidWallets())
          .where((w) => w.type == WalletType.NATIVE)
          .toList();

  var futures = keyWords.map((keyword) async {
    var pKidResult = await client.getPKidDoc(keyword);
    return pKidResult.containsKey('data') && pKidResult.containsKey('success')
        ? jsonDecode(pKidResult['data'])
        : {};
  });

  var pKidResult = await Future.wait(futures);
  Map<int, dynamic> dataMap = pKidResult.asMap();

  await handleKYCData(dataMap[0], dataMap[1], wallets.first.seed);
}

Future<void> handleKYCData(
    Map<dynamic, dynamic> emailData, Map<dynamic, dynamic> phoneData, String walletAddress) async {
  final idenfyServiceUrl = Globals().idenfyServiceUrl;
  final identityVerificationStatus =
      await getVerificationStatus(address: walletAddress, idenfyServiceUrl: idenfyServiceUrl);

  await saveCorrectVerificationStates(
      emailData, phoneData, identityVerificationStatus);

  bool? isEmailVerified = await getIsEmailVerified();
  bool? isPhoneVerified = await getIsPhoneVerified();
  bool? isIdentityVerified = await getIsIdentityVerified();

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

  if (isIdentityVerified == true) {
    Globals().identityVerified.value = true;
    final data = await getVerificationData(walletAddress);
    final firstName = utf8.decode(latin1.encode(data.orgFirstName!));
    final lastName = utf8.decode(latin1.encode(data.orgLastName!));
    await saveIdentity('$lastName $firstName', data.docIssuingCountry,
        data.docDob, data.docSex, data.idenfyRef, walletAddress);
  }
}

Future<void> saveCorrectVerificationStates(
    Map<dynamic, dynamic> emailData,
    Map<dynamic, dynamic> phoneData,
    VerificationStatus identityVerificationStatus) async {
  if (identityVerificationStatus.status == VerificationState.VERIFIED) {
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
  String? emailValue =
      email.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  return validateEmail(emailValue);
}
