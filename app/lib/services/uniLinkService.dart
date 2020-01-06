import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/Events/UniLinkEvent.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:threebotlogin/services/socketService.dart';
import 'package:threebotlogin/services/userService.dart';

BuildContext ctx;
Map<String, dynamic> data = {
  'doubleName': '',
  'mobile': true,
  'firstTime': false,
  'sid': 'random',
  'state': ''
};

checkWhatPageToOpen(UniLinkEvent e) async {
  Uri link = e.link;
  BuildContext context = e.context;
  BackendConnection connection = e.connection;

  String doubleName = await getDoubleName();
  if (context != null) {
    ctx = context;
  }
  if (link.host == 'login') {
    var state = link.queryParameters['state'];
    if (doubleName != null) {
      data['doubleName'] = doubleName;
      data['state'] = state;

      bool autoLogin = false;
      var scope = jsonDecode(link.queryParameters['scope']);
      if (scope['trustedDevice'] != null) {
        var trustedDevice = scope['trustedDevice'];
        if (await isTrustedDevice(
            link.queryParameters['appId'], trustedDevice)) {
          print('you are logged in');
          autoLogin = true;
        }
      }

      // send login request
      connection.socketLoginMobile(data);

      var loggedIn = await Navigator.push(
          ctx,
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
