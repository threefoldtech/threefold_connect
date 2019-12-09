import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/services/cryptoService.dart';

import '3botService.dart';
import 'cryptoService.dart';

Future<void> savePin(pin) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('pin');
  prefs.setString('pin', pin);
}

Future<String> getPin() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin');
}

Future<void> savePublicKey(key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('publickey');
  prefs.setString('publickey', key);
}

Future<String> getPublicKey() async {
  final prefs = await SharedPreferences.getInstance();

  // Older applications don't have the publickey stored yet, let's retrieve it.
  if (prefs.getString('publickey') == null ||
      prefs.getString('publickey').isEmpty) {
    var userInfoResponse = await getUserInfo(await getDoubleName());

    if (userInfoResponse.statusCode != 200) {
      throw new Exception('User not found');
    }

    var userInfo = json.decode(userInfoResponse.body);

    if (userInfo['publicKey'] != null) {
      throw new Exception('Seed phrase does not correspond to given name');
    }

    prefs.setString("publickey", userInfo['publicKey']);
  }

  return prefs.getString('publickey');
}

Future<void> savePrivateKey(key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('privatekey');
  prefs.setString('privatekey', key);
}

Future<String> getPrivateKey() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('privatekey');
}

Future<void> savePhrase(phrase) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('phrase');
  prefs.setString('phrase', phrase);
}

Future<String> getPhrase() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('phrase');
}

Future<void> saveDoubleName(doubleName) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('doubleName');
  prefs.setString('doubleName', doubleName);
}

Future<String> getDoubleName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('doubleName');
}

Future<void> removeEmail() async {
  final prefs = await SharedPreferences.getInstance();

  prefs.remove('email');
  prefs.remove('emailVerified');
}

Future<void> saveEmail(String email, bool verified) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('email');
  prefs.setString('email', email);

  prefs.remove('emailVerified');
  prefs.setBool('emailVerified', verified);
}

Future<Map<String, Object>> getEmail() async {
  final prefs = await SharedPreferences.getInstance();

  return {
    'email': prefs.getString('email'),
    'verified': prefs.getBool('emailVerified') != null &&
        prefs.getBool('emailVerified') &&
        prefs.getString('signedEmailIdentifier') != null &&
        prefs.getString('signedEmailIdentifier').isNotEmpty
  };
}

Future<void> removeSignedEmailIdentifier() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove("signedEmailIdentifier");
}

Future<void> saveSignedEmailIdentifier(signedEmailIdentifier) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('signedEmailIdentifier', signedEmailIdentifier);
}

Future<String> getSignedEmailIdentifier() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('signedEmailIdentifier');
}

Future<Map<String, Object>> getKeys(String appId, String doubleName) async {
  return await generateDerivedKeypair(appId, doubleName);
}

Future<String> getDerivedSeed(String appId) async {
  return await generateDerivedSeed(appId);
}

Future<void> saveFingerprint(fingerprint) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('fingerprint');
  prefs.setBool('fingerprint', fingerprint);
}

Future<bool> getFingerprint() async {
  final prefs = await SharedPreferences.getInstance();
  bool result = prefs.getBool('fingerprint');

  if (result == null) {
    await prefs.setBool('fingerprint', false);
    result = prefs.getBool('fingerprint');
  }

  return result;
}

Future<void> saveLoginToken(loginToken) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('loginToken');
  prefs.setString('loginToken', loginToken);
}

Future<String> getLoginToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('loginToken');
}

Future<void> saveScopePermissions(scopePermissions) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('scopePermissions');
  prefs.setString('scopePermissions', scopePermissions);
}

Future<String> getScopePermissions() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('scopePermissions');
}

Future<bool> clearData() async {
  final prefs = await SharedPreferences.getInstance();
  Response response;
  try {
    response = await removeDeviceId(prefs.getString('doubleName'));
    await removeDeviceId(prefs.getString('doubleName'));
  } catch (e) {
    print(e);
    response = null;
  }

  if (response != null && response.statusCode == 200) {
    prefs.clear();
    return true;
  } else {
    print("Something went wrong while removing your account");
    return false;
  }
}
