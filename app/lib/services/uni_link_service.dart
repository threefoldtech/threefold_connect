import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redirection/redirection.dart';
import 'package:threebotlogin/events/uni_link_event.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/models/scope.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/login_screen.dart';
import 'package:threebotlogin/services/user_service.dart';

class UniLinkService {
  static void handleUniLink(UniLinkEvent e) async {
    Uri link = e.link;
    BuildContext context = e.context;

    if (link != null) {
      String jsonScope = link.queryParameters['scope'];
      String state = link.queryParameters['state'];

      if (jsonScope == null && (state == null || state == "undefined")) {
        return;
      }
    }

    Login login = queryParametersToLogin(link.queryParameters);
    String previousState = await getPreviousState();

    if (login.state == previousState) {
      return;
    }

    String pin = await getPin();

    bool authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
            correctPin: pin, userMessage: "sign your attempt."),
      ),
    );

    if (authenticated != null && authenticated) {
      bool loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(login),
        ),
      );

      if (loggedIn != null && loggedIn) {
        bool stateSaved = await savePreviousState(login.state);
        
        if (stateSaved) {
          if (Platform.isAndroid) {
            await SystemNavigator.pop();
          } else if (Platform.isIOS) {
            bool didRedirect = await Redirection.redirect();
            print(didRedirect);
          }
        }
      }
    }
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
      redirecturl: map['redirecturl']);
}
