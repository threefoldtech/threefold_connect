import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter_pkid/flutter_pkid.dart';

import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet_data.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';

import '../app_config.dart';

String pKidUrl = AppConfig().pKidUrl();

Future<void> savePin(String pin) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('pin');
  prefs.setString('pin', pin);
}

Future<String?> getPin() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin');
}

Future<void> savePublicKey(Uint8List publicKey) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('publicKey');

  String encodedPublicKey = base64.encode(publicKey);
  prefs.setString('publicKey', encodedPublicKey);
}

Future<Uint8List> getPublicKey() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool? isPublicKeyFixed = await getIsPublicKeyFixed();

  if (isPublicKeyFixed == true) {
    String? encodedPublicKey = prefs.getString('publicKey');
    return base64.decode(encodedPublicKey!);
  }

  var userInfoResponse = await getUserInfo(await getDoubleName());
  if (userInfoResponse.statusCode != 200) {
    throw new Exception('User not found');
  }

  var userInfo = json.decode(userInfoResponse.body);
  var done = await prefs.setString("publicKey", userInfo['publicKey']);

  if (done && prefs.getString('publicKey') == userInfo['publicKey']) {
    setPublicKeyFixed();
  }

  String? encodedPublicKey = prefs.getString('publicKey');
  return base64.decode(encodedPublicKey!);
}

Future<Map<String, String>> getEdCurveKeys() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? pkEd = prefs.getString('publicKey');
  final String? skEd = prefs.getString('privateKey');

  final String pkCurve = base64
      .encode(Sodium.cryptoSignEd25519PkToCurve25519(base64.decode(pkEd!)));
  final String skCurve = base64
      .encode(Sodium.cryptoSignEd25519SkToCurve25519(base64.decode(skEd!)));

  return {
    'signingPublicKey': hex.encode(base64.decode(pkEd)),
    'signingPrivateKey': hex.encode(base64.decode(skEd)),
    'encryptionPublicKey': hex.encode(base64.decode(pkCurve)),
    'encryptionPrivateKey': hex.encode(base64.decode(skCurve))
  };
}

Future<void> setPublicKeyFixed() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isPublicKeyFixed', true);
}

Future<bool?> getIsPublicKeyFixed() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getBool('isPublicKeyFixed') == null) {
    return false;
  }

  return prefs.getBool('isPublicKeyFixed');
}

Future<void> savePrivateKey(Uint8List privateKey) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('privateKey');

  String encodedPrivateKey = base64.encode(privateKey);
  prefs.setString('privateKey', encodedPrivateKey);
}

Future<Uint8List> getPrivateKey() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String? privateKey = prefs.getString('privateKey');
  Uint8List decodedPrivateKey = base64.decode(privateKey!);

  return decodedPrivateKey;
}

Future<void> savePhrase(String phrase) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('seedPhrase');

  prefs.setString('seedPhrase', phrase);
}

Future<String?> getPhrase() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('seedPhrase');
}

Future<void> saveLocationId(String locationId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  List<dynamic> locationIdList = await getLocationIdList();

  locationIdList.add(locationId);

  String locationIdListAsJson = jsonEncode(locationIdList);

  prefs.remove('locationIdList');
  prefs.setString('locationIdList', locationIdListAsJson);
}

Future<List<dynamic>> getLocationIdList() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    String? locationIdListAsJson = prefs.getString('locationIdList');
    List<dynamic> locationIdList = jsonDecode(locationIdListAsJson!);

    return locationIdList;
  } catch (_) {
    return [];
  }
}

Future<void> saveDoubleName(String doubleName) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('doubleName');
  prefs.setString('doubleName', doubleName);
}

Future<String?> getDoubleName() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('doubleName');
}

Future<void> removeEmail() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.remove('email');
  prefs.remove('emailVerified');
}

Future<void> saveEmail(String email, String signedEmailIdentifier) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.remove('email');
  prefs.remove('signedEmailIdentifier');
  prefs.remove('emailVerified');

  prefs.setString('email', email);

  if (signedEmailIdentifier != null) {
    prefs.setString('signedEmailIdentifier', signedEmailIdentifier);

    Map<String, dynamic> keyPair =
        await generateKeyPairFromSeedPhrase(await getPhrase());

    var client = FlutterPkid(pkidUrl, keyPair);
    client.setPKidDoc('email',
        json.encode({'email': email, 'sei': signedEmailIdentifier}), keyPair);
  }

  Globals().emailVerified.value = (signedEmailIdentifier != null);
}

Future<Map<String, dynamic>> getIdentity() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'identityName': prefs.getString('identityName'),
    'signedIdentityNameIdentifier':
        prefs.getString('signedIdentityNameIdentifier'),
    'identityCountry': prefs.getString('identityCountry'),
    'signedIdentityCountryIdentifier':
        prefs.getString('signedIdentityCountryIdentifier'),
    'identityDOB': prefs.getString('identityDOB'),
    'signedIdentityDOBIdentifier':
        prefs.getString('signedIdentityDOBIdentifier'),
    'identityDocumentMeta': prefs.getString('identityDocumentMeta'),
    'signedIdentityDocumentMetaIdentifier':
        prefs.getString('signedIdentityDocumentMetaIdentifier'),
    'identityGender': prefs.getString('identityGender'),
    'signedIdentityGenderIdentifier':
        prefs.getString('signedIdentityGenderIdentifier'),
  };
}

Future<void> saveIdentity(
    Map<String, dynamic> identityName,
    String signedIdentityNameIdentifier,
    String identityCountry,
    String signedIdentityCountryIdentifier,
    String identityDOB,
    String signedIdentityDOBIdentifier,
    Map<String, dynamic> identityDocumentMeta,
    String signedIdentityDocumentMetaIdentifier,
    String identityGender,
    String signedIdentityGenderIdentifier) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('identityName');
  prefs.remove('identityCountry');
  prefs.remove('identityDOB');
  prefs.remove('identityDocumentMeta');
  prefs.remove('identityGender');

  prefs.setString('identityName', jsonEncode(identityName));
  prefs.setString('identityCountry', identityCountry);
  prefs.setString('identityDOB', identityDOB);
  prefs.setString('identityDocumentMeta', jsonEncode(identityDocumentMeta));
  prefs.setString('identityGender', identityGender);

  prefs.setString('signedIdentityNameIdentifier', signedIdentityNameIdentifier);
  prefs.setString(
      'signedIdentityCountryIdentifier',
      signedIdentityCountryIdentifier == 'null'
          ? 'test'
          : signedIdentityCountryIdentifier);
  prefs.setString('signedIdentityDOBIdentifier', signedIdentityDOBIdentifier);
  prefs.setString('signedIdentityDocumentMetaIdentifier',
      signedIdentityDocumentMetaIdentifier);
  prefs.setString(
      'signedIdentityGenderIdentifier', signedIdentityGenderIdentifier);

  prefs.remove('identityVerified');

  Map<String, dynamic> keyPair =
      await generateKeyPairFromSeedPhrase(await getPhrase());
  var client = FlutterPkid(pkidUrl, keyPair);
  client.setPKidDoc(
      'identity',
      json.encode({
        'identityName': jsonEncode(identityName),
        'signedIdentityNameIdentifier': signedIdentityNameIdentifier,
        'identityCountry': identityCountry,
        'signedIdentityCountryIdentifier': signedIdentityCountryIdentifier,
        'identityDOB': identityDOB,
        'signedIdentityDOBIdentifier': signedIdentityDOBIdentifier,
        'identityDocumentMeta': jsonEncode(identityDocumentMeta),
        'signedIdentityDocumentMetaIdentifier':
            signedIdentityDocumentMetaIdentifier,
        'identityGender': identityGender,
        'signedIdentityGenderIdentifier': signedIdentityGenderIdentifier
      }),
      keyPair);

  Globals().identityVerified.value = (signedIdentityNameIdentifier != null);
}

Future<void> removeIdentity() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('identityName');
  prefs.remove('identityCountry');
  prefs.remove('identityDOB');
  prefs.remove('identityDocumentMeta');
  prefs.remove('identityGender');
  prefs.remove('identityVerified');
}

Future<bool> getIsEmailVerified() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isEmailVerified');
}

Future<bool> getIsPhoneVerified() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isPhoneVerified');
}

Future<bool> getIsIdentityVerified() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isIdentityVerified');
}

Future<void> setIsEmailVerified(bool isEmailVerified) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool('isEmailVerified', isEmailVerified);
}

Future<void> setIsPhoneVerified(bool isPhoneVerified) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool('isPhoneVerified', isPhoneVerified);
}

Future<void> setIsIdentityVerified(bool isIdentityVerified) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool('isIdentityVerified', isIdentityVerified);
}

Future<void> removePhone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.remove('phone');
  prefs.remove('phoneVerified');
}

Future<void> savePhone(String phone, String signedPhoneIdentifier) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('phone');
  prefs.setString('phone', phone);

  prefs.remove('phoneVerified');

  if (signedPhoneIdentifier != null) {
    prefs.setString('signedPhoneIdentifier', signedPhoneIdentifier);

    Map<String, dynamic> keyPair =
        await generateKeyPairFromSeedPhrase(await getPhrase());
    var client = FlutterPkid(pkidUrl, keyPair);
    client.setPKidDoc('phone',
        json.encode({'phone': phone, 'spi': signedPhoneIdentifier}), keyPair);
  }

  Globals().phoneVerified.value = (signedPhoneIdentifier != null);
}

Future<Map<String, Object>> getEmail() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'email': prefs.getString('email'),
    'sei': prefs.getString('signedEmailIdentifier')
  };
}

Future<Map<String, Object>> getPhone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'phone': prefs.getString('phone'),
    'spi': prefs.getString('signedPhoneIdentifier')
  };
}

Future<Map<String, Object>> getKeys(String appId, String doubleName) async {
  return await generateDerivedKeypair(appId, doubleName);
}

Future<String> getDerivedSeed(String appId) async {
  return await generateDerivedSeed(appId);
}

Future<void> saveFingerprint(fingerprint) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('fingerprint');
  prefs.setBool('fingerprint', fingerprint);
}

Future<bool> getFingerprint() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool result = prefs.getBool('fingerprint');

  if (result == null) {
    await prefs.setBool('fingerprint', false);
    result = prefs.getBool('fingerprint');
  }

  return result;
}

Future<void> saveScopePermissions(scopePermissions) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('scopePermissions');
  prefs.setString('scopePermissions', scopePermissions);
}

Future<String> getScopePermissions() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('scopePermissions');
}

Future<void> savePreviousScopePermissions(
    String appId, String scopePermissions) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('$appId-scopePreviousPermissions');
  await prefs.setString('$appId-scopePreviousPermissions', scopePermissions);
}

Future<String> getPreviousScopePermissions(String appId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('$appId-scopePreviousPermissions');
}

Future<bool> isTrustedDevice(String appId, String trustedDevice) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String trustedDeviceApp = prefs.getString('$appId-trusted');
  if (trustedDeviceApp == null) return false;

  return trustedDeviceApp == trustedDevice;
}

Future<void> saveTrustedDevice(String appId, String trustedDeviceId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('$appId-trusted');
  prefs.setString('$appId-trusted', trustedDeviceId);
}

Future<void> saveInitDone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('initDone', true);
}

Future<bool> getInitDone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool initDone = prefs.getBool('initDone');
  if (initDone == null) {
    initDone = false;
  }
  return initDone;
}

Future<bool> savePreviousState(String state) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.setString("previousState", state);
}

Future<String> getPreviousState() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("previousState");
}

Future<bool> clearData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool cleared = await prefs.clear();
  saveInitDone();
  return cleared;
}

Future<void> saveWallets(List<WalletData> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.remove('walletData');
  await prefs.setString('walletData', jsonEncode(data));
}

Future<List<WalletData>> getWallets() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var string = prefs.getString('walletData');

  if (string == null) {
    return [];
  }

  var jsonDecoded = jsonDecode(string);

  List<WalletData> walletData = [];
  for (var data in jsonDecoded) {
    walletData.add(WalletData(data['name'], data['chain'], data['address']));
  }
  return walletData;
}
