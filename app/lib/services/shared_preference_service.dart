import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet_data.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/tweetnacl.dart' show TweetNaClExt;

///
///
/// Methods for encryption / signing
///
///

Future<Uint8List> getPublicKey() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool? isPublicKeyFixed = await getIsPublicKeyFixed();

  if (isPublicKeyFixed == true) {
    String? encodedPublicKey = prefs.getString('publickey');
    return base64.decode(encodedPublicKey!);
  }

  var userInfoResponse = await getUserInfo(await getDoubleName());
  if (userInfoResponse.statusCode != 200) {
    throw Exception('User not found');
  }

  var userInfo = json.decode(userInfoResponse.body);
  var done = await prefs.setString('publickey', userInfo['publicKey']);

  if (done && prefs.getString('publickey') == userInfo['publicKey']) {
    setPublicKeyFixed();
  }

  String? encodedPublicKey = prefs.getString('publickey');
  return base64.decode(encodedPublicKey!);
}

Future<void> savePublicKey(Uint8List publicKey) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('publickey');

  String encodedPublicKey = base64.encode(publicKey);
  prefs.setString('publickey', encodedPublicKey);
}

Future<bool?> getIsPublicKeyFixed() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getBool('isPublicKeyFixed') == null) {
    return false;
  }

  return prefs.getBool('isPublicKeyFixed');
}

Future<void> setPublicKeyFixed() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isPublicKeyFixed', true);
}

Future<Uint8List> getPrivateKey() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String? privateKey = prefs.getString('privatekey');
  Uint8List decodedPrivateKey = base64.decode(privateKey!);

  return decodedPrivateKey;
}

Future<void> savePrivateKey(Uint8List privateKey) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('privatekey');

  String encodedPrivateKey = base64.encode(privateKey);
  prefs.setString('privatekey', encodedPrivateKey);
}

Future<Map<String, String>> getEdCurveKeys() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? pkEd = prefs.getString('publickey');
  final String? skEd = prefs.getString('privatekey');

  final pkCurve = Uint8List(32);
  TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(
      pkCurve, base64.decode(pkEd!));
  final String pkCurveEncoded = base64.encode(Uint8List.fromList(pkCurve));

  final skCurve = Uint8List(32);
  TweetNaClExt.crypto_sign_ed25519_sk_to_x25519_sk(
      skCurve, base64.decode(skEd!));
  final String skCurveEncoded = base64.encode(Uint8List.fromList(skCurve));

  return {
    'signingPublicKey': hex.encode(base64.decode(pkEd)),
    'signingPrivateKey': hex.encode(base64.decode(skEd)),
    'encryptionPublicKey': hex.encode(base64.decode(pkCurveEncoded)),
    'encryptionPrivateKey': hex.encode(base64.decode(skCurveEncoded))
  };
}

Future<void> savePhrase(String phrase) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('phrase');

  prefs.setString('phrase', phrase);
}

Future<String?> getPhrase() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('phrase');
}

Future<void> saveTwinId(int twinId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('twinId');

  prefs.setInt('twinId', twinId);
  updateUserData("twinId", twinId.toString());
}

Future<int?> getTwinId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('twinId');
}

///
///
/// Email methods in Shared Preferences
///
///

Future<void> setIsEmailVerified(bool isEmailVerified) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isEmailVerified', isEmailVerified);
}

Future<bool?> getIsEmailVerified() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isEmailVerified');
}

Future<Map<String, String?>> getEmail() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'email': prefs.getString('email'),
    'sei': prefs.getString('signedEmailIdentifier')
  };
}

Future<void> saveEmail(String email, String? signedEmailIdentifier) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.remove('email');
  prefs.remove('signedEmailIdentifier');
  prefs.remove('emailVerified');

  prefs.setString('email', email);

  FlutterPkid client = await getPkidClient();

  if (signedEmailIdentifier != null) {
    Globals().emailVerified.value = true;
    prefs.setString('signedEmailIdentifier', signedEmailIdentifier);
    client.setPKidDoc(
        'email', json.encode({'email': email, 'sei': signedEmailIdentifier}));
    updateUserData("email", email);
    return;
  }

  Globals().emailVerified.value = false;
  client.setPKidDoc('email', json.encode({'email': email}));
}

///
///
/// Phone methods in Shared Preferences
///
///

Future<void> setIsPhoneVerified(bool isPhoneVerified) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isPhoneVerified', isPhoneVerified);
}

Future<bool?> getIsPhoneVerified() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isPhoneVerified');
}

Future<Map<String, String?>> getPhone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'phone': prefs.getString('phone'),
    'spi': prefs.getString('signedPhoneIdentifier')
  };
}

Future<void> savePhone(String phone, String? signedPhoneIdentifier) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.remove('phone');
  prefs.remove('phoneVerified');
  prefs.remove('signedPhoneIdentifier');

  prefs.setString('phone', phone);

  FlutterPkid client = await getPkidClient();

  if (signedPhoneIdentifier != null) {
    Globals().phoneVerified.value = true;
    prefs.setString('signedPhoneIdentifier', signedPhoneIdentifier);
    client.setPKidDoc(
        'phone', json.encode({'phone': phone, 'spi': signedPhoneIdentifier}));
    updateUserData("phone", phone);
    return;
  }

  Globals().phoneVerified.value = false;
  client.setPKidDoc('phone', json.encode({'phone': phone}));
}

///
///
/// Identity methods in Shared Preferences
///
///

Future<void> setIsIdentityVerified(bool isIdentityVerified) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isIdentityVerified', isIdentityVerified);
}

Future<bool?> getIsIdentityVerified() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isIdentityVerified');
}

Future<Map<String, dynamic>> getIdentity() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'identityName': prefs.getString('identityName'),
    'identityCountry': prefs.getString('identityCountry'),
    'identityDOB': prefs.getString('identityDOB'),
    'identityGender': prefs.getString('identityGender'),
  };
}

Future<void> saveIdentity(String? identityName, String? identityCountry,
    String? identityDOB, String? identityGender, String? referenceId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('identityName');
  prefs.remove('identityCountry');
  prefs.remove('identityDOB');
  prefs.remove('identityGender');

  prefs.setString('identityName', identityName!);
  prefs.setString('identityCountry', identityCountry!);
  prefs.setString('identityDOB', identityDOB!);
  prefs.setString('identityGender', identityGender!);

  updateUserData('identity_reference', referenceId!);
  Globals().identityVerified.value = true;
}

///
///
/// Methods for derived seed
///
///

Future<Uint8List> getDerivedSeed(String appId) async {
  return await generateDerivedSeed(appId);
}

///
///
/// Methods for authentication
///
///

Future<void> savePin(String pin) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('pin');
  prefs.setString('pin', pin);
}

Future<String?> getPin() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin');
}

Future<void> saveFingerprint(fingerprint) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('useFingerPrint');
  prefs.setBool('useFingerPrint', fingerprint);
}

Future<bool?> getFingerprint() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? result = prefs.getBool('useFingerPrint');

  if (result == null) {
    prefs.setBool('useFingerPrint', false);
    result = prefs.getBool('useFingerPrint');
  }

  return result;
}

///
///
/// Methods for login permissions
///
///

Future<void> saveScopePermissions(String scopePermissions) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('scopePermissions');
  prefs.setString('scopePermissions', scopePermissions);
}

Future<String?> getScopePermissions() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('scopePermissions');
}

Future<void> savePreviousScopePermissions(
    String appId, String? scopePermissions) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('$appId-scopePreviousPermissions');
  await prefs.setString('$appId-scopePreviousPermissions', scopePermissions!);
}

Future<String?> getPreviousScopePermissions(String appId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('$appId-scopePreviousPermissions');
}

///
///
/// Methods for initialization
///
///

Future<void> saveInitDone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('initDone', true);
}

Future<bool> getInitDone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool? initDone = prefs.getBool('initDone');
  if (initDone == null) {
    prefs.setBool('initDone', false);
    initDone = prefs.getBool('initDone');
  }

  bool isInitDone = initDone == true;
  return isInitDone;
}

///
///
/// Methods for unilinks
///
///

Future<bool> savePreviousState(String state) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.setString('previousState', state);
}

Future<String?> getPreviousState() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('previousState');
}

///
///
/// Methods for Wallets
///
///

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

///
///
/// Globals
///
///

Future<bool> clearData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool cleared = await prefs.clear();
  saveInitDone();
  return cleared;
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

  String? locationIdListAsJson = prefs.getString('locationIdList');

  List<dynamic> locationIdList = [];

  if (locationIdListAsJson != null) {
    locationIdList = jsonDecode(locationIdListAsJson);
  } else {
    locationIdList = [];
  }

  return locationIdList;
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

///
///
/// Migration problems
///
///

// In the past there was a mapping mistake by Lennert in the initial migration to PKID
// This has been solved in a second patch but we want to make sure all the users get the right fix
Future<bool?> isPKidMigrationIssueSolved() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isPkidMigrationIssueSolved');
}

Future<void> setPKidMigrationIssueSolved(bool isFixed) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isPkidMigrationIssueSolved', isFixed);
}

Future<void> setTheme(String theme) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('theme');

  prefs.setString('theme', theme);
}

Future<String?> getTheme() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getString('theme');
}
