import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/WebviewService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void initFirebaseMessagingListener(context) async {
  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      logger.log('On message $message');
      openLogin(context, message);
    },
    onLaunch: (Map<String, dynamic> message) async {
      logger.log('On launch $message');
      openLogin(context, message);
    },
    onResume: (Map<String, dynamic> message) async {
      logger.log('On resume $message');
      openLogin(context, message);
    },
  );

  _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true));

  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    logger.log("Settings registered: $settings");
  });
}

Future openLogin(context, message) async {
  var data = message['data'];

  if (Platform.isIOS) {
    data = message;
  }

  if (data['logintoken'] != null) {
    if (data['logintoken'] == await getLoginToken()) {
      var state = data['state'];
      var publicKey = data['appPublicKey'];
      var privateKey = getPrivateKey();
      var email = getEmail();
      var keys = getKeys(data['appId'], await getDoubleName());

      var signedHash = signData(state, await privateKey);
      var scope = {};
      var dataToSend;

      if (data['scope'] != null) {
        if (data['scope'].split(",").contains('user:email')) {
          scope['email'] = await email;
        }

        if (data['scope'].split(",").contains('user:keys')) {
          scope['keys'] = await keys;
        }
      }

      if (scope.isNotEmpty) {
        logger.log(scope.isEmpty);
        dataToSend =
            await encrypt(jsonEncode(scope), publicKey, await privateKey);
      }
      sendData(state, await signedHash, dataToSend, null);
    }
  } else {
    logger.log(data['type']);
    if (data['type'] == 'login' && data['mobile'] != 'true') {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen(data)));
          hideWebviews();
    } else if (data['type'] == 'email_verification') {
      getEmail().then((email) async {
        if (email['email'] != null && (await getSignedEmailIdentifier()) == null) {
          var tmpDoubleName = (await getDoubleName()).toLowerCase();

          getSignedEmailIdentifierFromOpenKYC(tmpDoubleName).then((response) async {
            var body = jsonDecode(response.body);

            var signedEmailIdentifier = body["signed_email_identifier"];

            if(signedEmailIdentifier != null && signedEmailIdentifier.isNotEmpty) {
              logger.log("Received signedEmailIdentifier: " + signedEmailIdentifier);

              var vsei = json.decode((await verifySignedEmailIdentifier(signedEmailIdentifier)).body);

              if(vsei != null && vsei["email"] == email["email"] && vsei["identifier"] == tmpDoubleName) {
                logger.log("Verified signedEmailIdentifier authenticity, saving data.");
                await saveEmail(vsei["email"], true);
                await saveSignedEmailIdentifier(signedEmailIdentifier);

                showDialog(
                  context: context,
                  builder: (BuildContext context) => CustomDialog(
                        image: Icons.email,
                        title: "Email verified",
                        description: new Text("Your email has been verfied!"),
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
              } else {
                logger.log("Couldn't verify authenticity, saving unverified email.");
                await saveEmail(email["email"], false);
                await removeSignedEmailIdentifier();
              }
            } else {
              logger.log("No valid signed email has been found, please redo the verification process.");
            }
          });
        }
      });
    }
  }
}
