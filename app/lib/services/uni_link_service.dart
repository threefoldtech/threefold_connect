import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redirection/redirection.dart';
import 'package:threebotlogin/events/uni_link_event.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/models/scope.dart';
import 'package:threebotlogin/models/sign.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/login_screen.dart';
import 'package:threebotlogin/screens/sign_screen.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/login_dialogs.dart';


class UniLinkService {
  static void handleUniLink(UniLinkEvent e) async {
    Uri link = e.link!;
    BuildContext context = e.context!;

    if (link.host == 'login') {
      return handleLoginUniLink(link, context);
    }

    if (link.host == 'sign') {
      return await handleSignUniLink(link, context);
    }

    print('Not valid');
  }
}

void handleLoginUniLink(Uri link, BuildContext context) async {
  String? jsonScope = link.queryParameters['scope'];
  String? state = link.queryParameters['state'];

  if (jsonScope == null && (state == null || state == "undefined")) {
    return;
  }

  Login login = queryParametersToLogin(link.queryParameters);
  String? previousState = await getPreviousState();

  if (login.state == previousState) {
    return;
  }

  String? pin = await getPin();

  bool? authenticated = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AuthenticationScreen(
          correctPin: pin!, userMessage: "sign your attempt."),
    ),
  );

  if (authenticated == null || authenticated == false) {
    return;
  }

  bool? loggedIn = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LoginScreen(login),
    ),
  );

  if (loggedIn == null || loggedIn == false) {
    return;
  }

  print(loggedIn);
  bool stateSaved = await savePreviousState(login.state.toString());
  
  await showLoggedInDialog(context);

  if (stateSaved) {
    if (Platform.isAndroid) {
      await SystemNavigator.pop();
    } else if (Platform.isIOS) {
      bool didRedirect = await Redirection.redirect();
      print(didRedirect);
    }
  }
}

Future<void> handleSignUniLink(Uri link, BuildContext context) async {
  print('This is the sign link');
  print(link);

  Map<String, String> queryParams = link.queryParameters;

  List<String> req = [
    'dataHash',
    'state',
    'appId',
    'dataUrl',
    'isJson',
    'friendlyName'
  ];

  bool isValidSignAttempt = true;

  req.forEach((element) {
    if (queryParams[element] == null || queryParams[element] == 'undefined') {
      isValidSignAttempt = false;
    }
  });

  if (!isValidSignAttempt) {
    print('One or more parameters are missing');
    return;
  }

  Sign sign = await queryParametersToSign(link.queryParameters);

  String? pin = await getPin();

  bool? authenticated = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AuthenticationScreen(
          correctPin: pin!, userMessage: "Sign your attempt."),
    ),
  );

  if (authenticated == null || authenticated == false) {
    return;
  }

  bool? loggedIn = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SignScreen(sign),
    ),
  );

  if (loggedIn == null || loggedIn == false) {
    return;
  }

  if (Platform.isAndroid) {
    await SystemNavigator.pop();
  } else if (Platform.isIOS) {
    bool didRedirect = await Redirection.redirect();
  }
}

Login queryParametersToLogin(Map<String, dynamic> map) {
  return Login(
      state: map['state'],
      isMobile: true,
      randomRoom: map['randomRoom'],
      scope: map['scope'] != null && map['scope'] != 'null'
          ? Scope.fromJson(jsonDecode(map['scope'] as String))
          : null,
      appId: map['appId'],
      appPublicKey: map['appPublicKey'],
      redirectUrl: map['redirecturl']);
}

// this.hashedDataUrl,
// this.dataUrl,
// this.friendlyName,
// this.isJson,
// this.appId,
// this.type,
// this.randomRoom,
// this.redirectUrl,
// this.state

Future<Sign> queryParametersToSign(Map<String, dynamic> map) async {
  return Sign(
      doubleName: await getDoubleName(),
      hashedDataUrl: map['dataHash'],
      dataUrl: map['dataUrl'],
      friendlyName: map['friendlyName'],
      isJson: map['isJson'] == 'true' ? true : false,
      appId: map['appId'],
      randomRoom: map['randomRoom'],
      redirectUrl: map['redirectUrl'],
      state: map['state']);
}
