import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/ChangePinScreen.dart';
import 'package:threebotlogin/screens/HomeScreen.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/screens/MainScreen.dart';
import 'package:threebotlogin/screens/MobileRegistrationScreen.dart';
import 'package:threebotlogin/screens/RegistrationWithoutScanScreen.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:threebotlogin/screens/UnregisteredScreen.dart';
import 'package:threebotlogin/services/socketService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

BuildContext ctx;
Map<String, dynamic> data = {
  'doubleName': '',
  'mobile': true,
  'firstTime': false,
  'sid': 'random',
  'state': ''
};

checkWhatPageToOpen(Uri link, BuildContext context) async {
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
      socketLoginMobile(data);

      Navigator.push(
          ctx,
          MaterialPageRoute(
              builder: (context) =>
                  LoginScreen(link.queryParameters, autoLogin: autoLogin)));
    } else {
      if (doubleName == null) {
        final bool registered = await Navigator.push(
            ctx,
            MaterialPageRoute(
                builder: (context) => MobileRegistrationScreen()));

        await Navigator.push(
            ctx, MaterialPageRoute(builder: (context) => ChangePinScreen()));
        if (registered != null && registered) {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SuccessfulScreen(
                      title: "Registered", text: "You are now registered.")));
          await Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (context) =>
                      MainScreen(initDone: true, registered: registered)));

          // Get the doublename and send a login request
          data['doubleName'] = await getDoubleName();
          socketLoginMobile(data);

          // After 2 seconds, show the login prompt
          Timer(
              Duration(seconds: 2),
              () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginScreen(link.queryParameters))));
        }
      }
    }
  }
  if (link.host == 'register') {
    await Navigator.push(ctx,
        MaterialPageRoute(builder: (context) => MobileRegistrationScreen()));
  } else if (link.host == "registeraccount") {
    // Check if we already have an account registered before showing this screen.
    String privateKey = await getPrivateKey();

    if (doubleName == null || privateKey == null) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileRegistrationScreen(
              doubleName: link.queryParameters['doubleName']),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomDialog(
          image: Icons.check,
          title: "You're already logged in",
          description: new Text(
              "We cannot create a new account, you already have an account registered on your device. Please restart the application if this message persists."),
          actions: <Widget>[
            FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }
}
