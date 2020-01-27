import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/events/uni_link_event.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/models/scope.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/login_screen.dart';
import 'package:threebotlogin/screens/successful_screen.dart';
import 'package:threebotlogin/services/user_service.dart';

class UniLinkService {
  static void handleUniLink(UniLinkEvent e) async {
    Uri link = e.link;
    BuildContext context = e.context;

    if (link != null) {
      String jsonScope = link.queryParameters['scope'];

      if (jsonScope == null) {
        return;
      }
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
      Login login = queryParametersToLogin(link.queryParameters);

      bool loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(login),
        ),
      );

      if (loggedIn != null && loggedIn) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessfulScreen(
                title: "Logged in",
                text: "You are now logged in. Return to browser."),
          ),
        );
      }
    }
  }
}

Login queryParametersToLogin(Map<String, dynamic> map) {
  return Login(
      state: map['state'],
      isMobile: true,
      signedRoom: map['signedRoom'],
      scope: Scope.fromJson(jsonDecode(map['scope'] as String)),
      appId: map['appId'],
      appPublicKey: map['appPublicKey'],
      redirecturl: map['redirecturl']);
}
