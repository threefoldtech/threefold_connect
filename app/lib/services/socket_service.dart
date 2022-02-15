import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/events/close_auth_event.dart';
import 'package:threebotlogin/events/close_socket_event.dart';
import 'package:threebotlogin/events/email_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_sign_event.dart';
import 'package:threebotlogin/events/new_login_event.dart';
import 'package:threebotlogin/events/phone_event.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/models/sign.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/login_screen.dart';
import 'package:threebotlogin/screens/sign_screen.dart';
import 'package:threebotlogin/screens/warning_screen.dart';
import 'package:threebotlogin/services/fingerprint_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/login_dialogs.dart';

class BackendConnection {
  late IO.Socket socket;

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
      int currentTimestamp = new DateTime.now().millisecondsSinceEpoch;

      if (data['created'] != null &&
          ((currentTimestamp - data['created']) / 1000) > Globals().loginTimeout) {
        print('We received an expired login attempt, ignoring it.');
        return;
      }
      Login loginData = await Login.createAndDecryptLoginObject(data);

      Events().emit(NewLoginEvent(loginData: loginData));
    });

    socket.on('sign', (dynamic data) async {
      Sign signData = await Sign.createAndDecryptSignObject(data);
      Events().emit(NewSignEvent(signData: signData));
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
  Map<String, String?> email = await getEmail();

  if (email['email'] == null) {
    return;
  }

  String doubleName = (await getDoubleName())!.toLowerCase();

  Response response = await getSignedEmailIdentifierFromOpenKYC(doubleName);
  if (response.statusCode != 200) {
    return;
  }

  Map<String, dynamic> body = jsonDecode(response.body);
  String? signedEmailIdentifier = body["signed_email_identifier"];

  if (signedEmailIdentifier == null || signedEmailIdentifier.isEmpty) {
    await saveEmail(email["email"]!, null);
  }

  var vSei = jsonDecode((await verifySignedEmailIdentifier(signedEmailIdentifier!)).body);
  if (vSei == null || vSei['email'] != email['email'] || vSei['identifier'] != doubleName) {
    return;
  }

  await setIsEmailVerified(true);
  await saveEmail(vSei["email"], signedEmailIdentifier);

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
}

Future phoneVerification(BuildContext context) async {
  Map<String, String?> phone = await getPhone();

  if (phone['phone'] == null) {
    return;
  }

  String doubleName = (await getDoubleName())!.toLowerCase();
  Response response = await getSignedPhoneIdentifierFromOpenKYC(doubleName);
  if (response.statusCode != 200) {
    return;
  }

  Map<String, dynamic> body = jsonDecode(response.body);
  String? signedPhoneIdentifier = body["signed_phone_identifier"];
  if (signedPhoneIdentifier == null || signedPhoneIdentifier.isEmpty) {
    await savePhone(phone["phone"]!, null);
  }

  var vSpi = jsonDecode((await verifySignedPhoneIdentifier(signedPhoneIdentifier!)).body);
  if (vSpi == null || vSpi['phone'] != phone['phone'] || vSpi['identifier'] != doubleName) {
    return;
  }

  await setIsPhoneVerified(true);
  await savePhone(vSpi["phone"], signedPhoneIdentifier);

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
}

Future showIdentityMessage(BuildContext context, String type) async {
  {
    if (type == 'unauthorized') {
      return showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          image: Icons.warning,
          title: "Identity verify timed out",
          description:
              "Your verification attempt has expired, please retry and finish the flow in under 10 minutes.",
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
  String doubleName = (await getDoubleName())!.toLowerCase();
  Response response = await getSignedIdentityIdentifierFromOpenKYC(doubleName);

  if (response.statusCode != 200) {
    return;
  }

  Map<String, dynamic> identifiersData = json.decode(response.body);

  String signedIdentityNameIdentifier = identifiersData["signed_identity_name_identifier"];
  String signedIdentityCountryIdentifier = identifiersData["signed_identity_country_identifier"];
  String signedIdentityDOBIdentifier = identifiersData["signed_identity_dob_identifier"];
  String signedIdentityDocumentMetaIdentifier =
      identifiersData["signed_identity_document_meta_identifier"];
  String signedIdentityGenderIdentifier = identifiersData["signed_identity_gender_identifier"];

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

  var verifiedSignedIdentityNameIdentifier =
      jsonDecode(identifiers["signedIdentityNameIdentifierVerified"]);
  var verifiedSignedIdentityCountryIdentifier =
      jsonDecode(identifiers["signedIdentityCountryIdentifierVerified"]);
  var verifiedSignedIdentityDOBIdentifier =
      jsonDecode(identifiers["signedIdentityDOBIdentifierVerified"]);
  var verifiedSignedIdentityDocumentMetaIdentifier =
      jsonDecode(identifiers["signedIdentityDocumentMetaIdentifierVerified"]);
  var verifiedSignedIdentityGenderIdentifier =
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

  await setIsIdentityVerified(true);

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


Future openSign(BuildContext ctx, Sign signData, BackendConnection backendConnection) async {
  String? messageType = signData.type;

  if (messageType == null || messageType != 'sign') {
    return;
  }

  String? pin = await getPin();
  Events().emit(CloseAuthEvent(close: true));

  bool? authenticated = await Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (context) => AuthenticationScreen(
          correctPin: pin!, userMessage: "sign your attempt"),
    ),
  );

  if (authenticated == null || authenticated == false) {
    return;
  }


  backendConnection.leaveRoom(signData.doubleName);

  bool? signAccepted = await Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (context) => SignScreen(signData),
    ),
  );

  if (signAccepted == null || signAccepted == false) {
    backendConnection.joinRoom(signData.doubleName);
    return;
  }

  backendConnection.joinRoom(signData.doubleName);
  await showSignedInDialog(ctx);
}


Future openLogin(BuildContext ctx, Login loginData, BackendConnection backendConnection) async {
  String? messageType = loginData.type;

  if (messageType == null || messageType != 'login' || loginData.isMobile == true) {
    return;
  }

  String? pin = await getPin();

  Events().emit(CloseAuthEvent(close: true));

  bool? authenticated = await Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (context) => AuthenticationScreen(
          correctPin: pin!, userMessage: "Sign your attempt.", loginData: loginData),
    ),
  );

  if (authenticated == null || authenticated == false) {
    return;
  }

  if (loginData.showWarning == true) {
    bool? warningScreenCompleted = await Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (context) => WarningScreen(),
      ),
    );

    if (warningScreenCompleted == null || !warningScreenCompleted) {
      return;
    }

    await saveLocationId(loginData.locationId!);
  }

  backendConnection.leaveRoom(loginData.doubleName);

  bool? loggedIn = await Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (context) => LoginScreen(loginData),
    ),
  );

  if (loggedIn == null || loggedIn == false) {
    backendConnection.joinRoom(loginData.doubleName);
    return;
  }

  backendConnection.joinRoom(loginData.doubleName);
  await showLoggedInDialog(ctx);
}
