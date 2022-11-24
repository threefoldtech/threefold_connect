import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:redirection/redirection.dart';
import 'package:threebotlogin/api/3bot/services/login.service.dart';
import 'package:threebotlogin/core/auth/pin/helpers/pin.helpers.dart';
import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';
import 'package:threebotlogin/login/classes/login.classes.dart';
import 'package:threebotlogin/login/classes/scope.classes.dart';
import 'package:threebotlogin/login/dialogs/login.dialogs.dart';
import 'package:threebotlogin/login/views/login.view.dart';
import 'package:threebotlogin/login/views/warning.view.dart';
import 'package:threebotlogin/sockets/enums/socket.enums.dart';

int parseImageId(String imageId) {
  if (imageId == '') {
    return 1;
  }
  return int.parse(imageId);
}

Future<void> openLogin(Login loginData) async {
  String? messageType = loginData.type;

  if (messageType == null || messageType != SocketListenerTypes.login) {
    return;
  }

  if (loginData.isMobile == true) {
    return;
  }

  bool? authenticated = await authenticateYourself();
  if (authenticated == null || !authenticated) {
    await cancelLogin();
    return;
  }

  if (loginData.showWarning == true && loginData.locationId != null) {
    bool? hasCompleted = await hasWarningCompleted(loginData.locationId!);

    if (hasCompleted == null || !hasCompleted) {
      return;
    }
  }

  bool? loggedIn = await Navigator.push(
    Globals().globalBuildContext,
    MaterialPageRoute(
      builder: (context) => LoginScreen(loginData),
    ),
  );

  if (loggedIn == null || !loggedIn) return;

  await showLoggedInDialog();
}

Future<void> openLoginMobile(Uri url) async {
  String? jsonScope = url.queryParameters['scope'];
  String? state = url.queryParameters['state'];

  if (jsonScope == null && (state == null)) {
    return;
  }

  Login login = queryParametersToLogin(url.queryParameters);
  String? previousState = await getPreviousState();

  if (login.state == previousState) {
    return;
  }

  bool? authenticated = await authenticateYourself();
  if (authenticated == null || !authenticated) {
    await cancelLogin();
    return;
  }

  bool? loggedIn = await Navigator.push(
    Globals().globalBuildContext,
    MaterialPageRoute(
      builder: (context) => LoginScreen(login),
    ),
  );

  if (loggedIn == null || !loggedIn) {
    return;
  }

  bool stateSaved = await setPreviousState(login.state.toString());

  await showLoggedInDialog();

  if (!stateSaved) return;
  if (Platform.isAndroid) {
    await SystemNavigator.pop();
    return;
  }

  await Redirection.redirect();
}

Future<bool?> hasWarningCompleted(String locationId) async {
  bool? warningScreenCompleted = await Navigator.push(
    Globals().globalBuildContext,
    MaterialPageRoute(
      builder: (context) => WarningScreen(),
    ),
  );

  if (warningScreenCompleted == null || !warningScreenCompleted) {
    return null;
  }

  await setLocationId(locationId);
  return true;
}

List<int> generateEmojiImageList(String randomImageId) {
  List<int> imageList = [];

  int correctImage = parseImageId(randomImageId);

  imageList.add(correctImage);

  int generated = 1;
  Random rng = new Random();

  while (generated <= 3) {
    int x = rng.nextInt(266) + 1;
    if (!imageList.contains(x)) {
      imageList.add(x);
      generated++;
    }
  }

  imageList.shuffle();
  return imageList;
}

bool isValidState(String? state) {
  if (state == null) return false;
  return RegExp(r"[^A-Za-z0-9]+").hasMatch(state);
}

Future<Map<String, dynamic>?> readScopeAsObject(String? scopePermissions, Uint8List dSeed) async {
  Map<String, dynamic>? scopePermissionsDecoded = jsonDecode(scopePermissions!);

  Map<String, dynamic> scope = {};

  if (scopePermissionsDecoded == null) return null;

  if (scopePermissionsDecoded['email'] == true) {
    scope['email'] = (await getEmail());
  }

  if (scopePermissionsDecoded['phone'] == true) {
    scope['phone'] = (await getPhone());
  }

  if (scopePermissionsDecoded['derivedSeed'] == true) {
    scope['derivedSeed'] = base64Encode(dSeed);
  }

  if (scopePermissionsDecoded['digitalTwin'] == true) {
    scope['digitalTwin'] = 'OK';
  }

  if (scopePermissionsDecoded['walletAddress'] == true) {
    scope['walletAddressData'] = {'address': scopePermissionsDecoded['walletAddressData']};
  }

  return scope;
}

Future<Map<String, String>> encryptLoginData(String publicKey, Map<String, dynamic>? scopeData) async {
  Uint8List sk = await getPrivateKey();
  Uint8List pk = base64.decode(publicKey);

  return await encrypt(jsonEncode(scopeData), pk, sk);
}

Future<void> addDigitalTwinToBackend(Uint8List derivedSeed, String appId) async {
  KeyPair dtKeyPair = await generateKeyPairFromEntropy(derivedSeed);
  String dtEncodedPublicKey = base64.encode(dtKeyPair.pk);

  addDigitalTwinDerivedPublicKeyToBackend(dtEncodedPublicKey, appId);
}

bool scopeIsEqual(Map<String, dynamic> appScope, Map<String, dynamic> userScope) {
  List<String> appScopeList = appScope.keys.toList();
  List<String> userScopeList = userScope.keys.toList();

  if (!listEquals(appScopeList, userScopeList)) {
    return false;
  }

  for (int i = 0; i < appScopeList.length; i++) {
    dynamic scopeValue1 = appScope[appScopeList[i]];
    dynamic scopeValue2 = userScope[userScopeList[i]];

    if (scopeValue1 == true && (scopeValue2 == false || scopeValue2 == null)) {
      return false;
    }

    if (scopeValue1 == null && (scopeValue2 == true || scopeValue2 == false)) {
      return false;
    }
  }

  return true;
}

Login queryParametersToLogin(Map<String, dynamic> map) {
  return Login(
      state: map['state'],
      isMobile: true,
      room: map['room'],
      scope: map['scope'] != null && map['scope'] != 'null' ? Scope.fromJson(jsonDecode(map['scope'] as String)) : null,
      appId: map['appId'],
      appPublicKey: map['appPublicKey'],
      redirectUrl: map['redirectUrl']);
}
