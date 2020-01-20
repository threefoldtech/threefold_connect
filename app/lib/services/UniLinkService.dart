import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/Events/UniLinkEvent.dart';
import 'package:threebotlogin/screens/AuthenticationScreen.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:threebotlogin/services/userService.dart';

class UniLinkService {
  static void handleUniLink(UniLinkEvent e) async {
    Uri link = e.link;
    BuildContext context = e.context;

    bool autoLogin = false;
    var scope = jsonDecode(link.queryParameters['scope']);
    if (scope['trustedDevice'] != null) {
      var trustedDevice = scope['trustedDevice'];
      if (await isTrustedDevice(link.queryParameters['appId'], trustedDevice)) {
        print('you are logged in');
        autoLogin = true;
      }
    }

    var pin = await getPin();

    bool authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
              correctPin: pin, userMessage: "sign your attempt"),
        ));

    if (authenticated != null && authenticated) {
      var loggedIn = await Navigator.push(
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
