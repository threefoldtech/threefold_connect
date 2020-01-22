import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/events/uni_link_event.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/login_screen.dart';
import 'package:threebotlogin/screens/successful_screen.dart';
import 'package:threebotlogin/services/user_service.dart';

class UniLinkService {
  static void handleUniLink(UniLinkEvent e) async {
    Uri link = e.link;
    BuildContext context = e.context;

    bool autoLogin = false;

    if (link != null) {
      String queryParameters = link.queryParameters['scope'];

      if (queryParameters != null) {
        Map<String, dynamic> scope = jsonDecode(queryParameters);
        if (scope != null && scope['trustedDevice'] != null) {
          String trustedDevice = scope['trustedDevice'];
          if (await isTrustedDevice(
              link.queryParameters['appId'], trustedDevice)) {
            print('you are logged in');
            autoLogin = true;
          }
        }
      } else {
        return;
      }
    }

    String pin = await getPin();

    bool authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
              correctPin: pin, userMessage: "sign your attempt"),
        ));

    if (authenticated != null && authenticated) {
      bool loggedIn = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginScreen(link.queryParameters, autoLogin: autoLogin)));

      if (loggedIn) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SuccessfulScreen(
                    title: "Logged in",
                    text: "You are now logged in. Return to browser.")));
      }
    }
  }
}
