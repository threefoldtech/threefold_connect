import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/events/close_auth_event.dart';
import 'package:threebotlogin/events/close_socket_event.dart';
import 'package:threebotlogin/events/email_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/new_login_event.dart';
import 'package:threebotlogin/events/phone_event.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/login_screen.dart';
import 'package:threebotlogin/screens/warning_screen.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class BackendConnection {
  IO.Socket socket;

  String doubleName;
  String threeBotSocketUrl = AppConfig().threeBotSocketUrl();

  BackendConnection(this.doubleName);

  init() async {
    print('Creating socket connection with $threeBotSocketUrl for $doubleName');

    socket = IO.io(threeBotSocketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'forceNew': true
    });

    socket.on('connect', (res) {
      print('[connect]');

      socket.emit('join', {'room': doubleName.toLowerCase(), 'app': true});
      print('Joined room: ' + doubleName.toLowerCase());
    });

    socket.on('email_verification', (_) {
      Events().emit(EmailEvent());
    });
    socket.on('sms_verification', (_) {
      Events().emit(PhoneEvent());
    });

    socket.on('login', (dynamic data) async {
      print('[login]');
      // var d = new DateTime.fromMillisecondsSinceEpoch(ts, isUtc: true);
      int currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

      if (data['created'] != null && ((currentTimestamp - data['created']) / 1000) > Globals().loginTimeout) {
        print('We received an expired login attempt, ignoring it.');
        return;
      }
      Login loginData = await Login.createAndDecryptLoginObject(data);

      Events().emit(NewLoginEvent(loginData: loginData));
    });

    socket.on('disconnect', (_) {
      print('disconnect');
    });

    Events().onEvent(CloseSocketEvent().runtimeType, closeSocketConnection);
  }

  void closeSocketConnection(CloseSocketEvent event) {
    print('Closing socket connection');

    print('Leaving room: ' + doubleName);
    socket.emit('leave', {'room': doubleName});

    socket.clearListeners();
    socket.disconnect();
    socket.close();
    socket.destroy();
  }

  void joinRoom(roomName) {
    print('Joining room: ' + roomName);
    socket.emit('join', {'room': roomName, 'app': true});
  }

  void leaveRoom(roomName) {
    print('Leaving room: ' + roomName);
    socket.emit('leave', {'room': roomName});
  }
}

Future emailVerification(BuildContext context) async {
  Map<String, Object> email = await getEmail();
  if (email['email'] != null) {
    String doubleName = (await getDoubleName()).toLowerCase();
    Response response = await getSignedEmailIdentifierFromOpenKYC(doubleName);

    if (response.statusCode != 200) {
      return;
    }

    Map<String, dynamic> body = jsonDecode(response.body);

    dynamic signedEmailIdentifier = body["signed_email_identifier"];

    if (signedEmailIdentifier != null && signedEmailIdentifier.isNotEmpty) {
      Map<String, dynamic> vsei = jsonDecode((await verifySignedEmailIdentifier(signedEmailIdentifier)).body);

      if (vsei != null && vsei["email"] == email["email"] && vsei["identifier"] == doubleName) {
        await saveKYCLevel(1);
        await saveEmail(vsei["email"], signedEmailIdentifier);

        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.email,
            title: "Email verified",
            description: "Your email has been verified!",
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
        await saveEmail(email["email"], null);
      }
    }
  }
}

Future phoneVerification(BuildContext context) async {
  Map<String, Object> phone = await getPhone();
  if (phone['phone'] != null) {
    String doubleName = (await getDoubleName()).toLowerCase();
    Response response = await getSignedPhoneIdentifierFromOpenKYC(doubleName);

    if (response.statusCode != 200) {
      return;
    }

    Map<String, dynamic> body = jsonDecode(response.body);

    dynamic signedPhoneIdentifier = body["signed_phone_identifier"];

    if (signedPhoneIdentifier != null && signedPhoneIdentifier.isNotEmpty) {
      Map<String, dynamic> vspi = jsonDecode((await verifySignedPhoneIdentifier(signedPhoneIdentifier)).body);

      if (vspi != null && vspi["phone"] == phone["phone"] && vspi["identifier"] == doubleName) {
        await saveKYCLevel(2);
        await savePhone(vspi["phone"], signedPhoneIdentifier);

        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.phone_android,
            title: "Phone verified",
            description: "Your phone has been verified!",
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
        await savePhone(phone["phone"], null);
      }
    }
  }
}

Future showIdentityMessage(BuildContext context, String type) async {
  {
    if (type == 'failed') {
      return showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          image: Icons.warning,
          title: "Identity verify failed",
          description: "Something went wrong.\nIf this issue persist, please contact support",
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

    return showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.check,
        title: "Identity verified",
        description: "Your identity has been verified successfully",
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

Future identityVerification(String reference) async {
  print('Verifying my ID');

  String doubleName = (await getDoubleName()).toLowerCase();
  Response response = await getSignedIdentityIdentifierFromOpenKYC(doubleName);

  if (response.statusCode != 200) {
    return;
  }

  Map<String, dynamic> identifiersData = json.decode(response.body);

  dynamic signedIdentityNameIdentifier = identifiersData["signed_identity_name_identifier"];
  dynamic signedIdentityCountryIdentifier = identifiersData["signed_identity_country_identifier"];
  dynamic signedIdentityDOBIdentifier = identifiersData["signed_identity_dob_identifier"];
  dynamic signedIdentityDocumentMetaIdentifier = identifiersData["signed_identity_document_meta_identifier"];
  dynamic signedIdentityGenderIdentifier = identifiersData["signed_identity_gender_identifier"];

  if (signedIdentityNameIdentifier.isEmpty ||
      signedIdentityCountryIdentifier.isEmpty ||
      signedIdentityDOBIdentifier.isEmpty ||
      signedIdentityDocumentMetaIdentifier.isEmpty ||
      signedIdentityGenderIdentifier.isEmpty) {
    return;
  }

  Map<String, dynamic> identifiers = jsonDecode((await verifySignedIdentityIdentifier(
          signedIdentityNameIdentifier,
          signedIdentityCountryIdentifier,
          signedIdentityDOBIdentifier,
          signedIdentityDocumentMetaIdentifier,
          signedIdentityGenderIdentifier,
          reference))
      .body);

  Map<String, dynamic> verifiedSignedIdentityNameIdentifier =
      jsonDecode(identifiers["signedIdentityNameIdentifierVerified"]);
  Map<String, dynamic> verifiedSignedIdentityCountryIdentifier =
      jsonDecode(identifiers["signedIdentityCountryIdentifierVerified"]);
  Map<String, dynamic> verifiedSignedIdentityDOBIdentifier =
      jsonDecode(identifiers["signedIdentityDOBIdentifierVerified"]);
  Map<String, dynamic> verifiedSignedIdentityDocumentMetaIdentifier =
      jsonDecode(identifiers["signedIdentityDocumentMetaIdentifierVerified"]);
  Map<String, dynamic> verifiedSignedIdentityGenderIdentifier =
      jsonDecode(identifiers["signedIdentityGenderIdentifierVerified"]);


  if (verifiedSignedIdentityNameIdentifier == null ||
      verifiedSignedIdentityNameIdentifier['identifier'].toString() != doubleName) {
    return;
  }

  if (verifiedSignedIdentityCountryIdentifier == null ||
      verifiedSignedIdentityCountryIdentifier['identifier'].toString() != doubleName) {
    return;
  }

  if (verifiedSignedIdentityDOBIdentifier == null ||
      verifiedSignedIdentityDOBIdentifier['identifier'].toString() != doubleName) {
    return;
  }

  if (verifiedSignedIdentityDocumentMetaIdentifier == null ||
      verifiedSignedIdentityDocumentMetaIdentifier['identifier'].toString() != doubleName) {
    return;
  }

  if (verifiedSignedIdentityGenderIdentifier == null ||
      verifiedSignedIdentityGenderIdentifier['identifier'].toString() != doubleName) {
    return;
  }

  print('SETTING KYC LEVEL TO 3');
  await saveKYCLevel(3);

  await saveIdentity(
      verifiedSignedIdentityNameIdentifier['name_data'],
      signedIdentityNameIdentifier,
      verifiedSignedIdentityCountryIdentifier['country_data'],
      signedIdentityCountryIdentifier,
      verifiedSignedIdentityDOBIdentifier['dob_data'],
      signedIdentityDOBIdentifier,
      verifiedSignedIdentityDocumentMetaIdentifier['document_meta_data'],
      signedIdentityDocumentMetaIdentifier,
      verifiedSignedIdentityGenderIdentifier['gender_data'],
      signedIdentityGenderIdentifier);

  return 'Verified';
}

Future openLogin(BuildContext context, Login loginData, BackendConnection backendConnection) async {
  String messageType = loginData.type;

  if (messageType == 'login' && !loginData.isMobile) {
    String pin = await getPin();

    Events().emit(CloseAuthEvent(close: true));

    bool authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AuthenticationScreen(correctPin: pin, userMessage: "sign your attempt.", loginData: loginData),
      ),
    );

    if (authenticated != null && authenticated) {
      if (loginData.showWarning) {
        bool warningScreenCompleted = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WarningScreen(),
          ),
        );

        if (warningScreenCompleted == null || !warningScreenCompleted) {
          return;
        }

        await saveLocationId(loginData.locationId);
      }

      backendConnection.leaveRoom(loginData.doubleName);

      bool loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(loginData),
        ),
      );

      if (loggedIn != null && loggedIn) {
        backendConnection.joinRoom(loginData.doubleName);

        await showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.check,
            title: 'Logged in',
            description: 'You are now logged in. Please return to your browser.',
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      } else {
        backendConnection.joinRoom(loginData.doubleName);
      }
    }
  }
}
