import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/events/close_auth_event.dart';
import 'package:threebotlogin/events/close_socket_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/new_login_event.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/home_screen.dart';
import 'package:threebotlogin/screens/login_screen.dart';
import 'package:threebotlogin/screens/successful_screen.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class BackendConnection {
  IO.Socket socket;

  String doubleName;
  String threeBotSocketUrl = AppConfig().threeBotSocketUrl();

  BackendConnection(this.doubleName);

  init() async {
    print('creating socket connection....');

    socket = IO.io(threeBotSocketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'forceNew': true
    });

    socket.on('connect', (res) {
      print('connected');
      // once a client has connected, we let him join a room
      socket.emit('join', {'room': doubleName.toLowerCase(), 'app': true});
      print('joined room');
    });

    socket.on('login', (dynamic data) async {
      print('[login]: Received data');
      print(data);

      Login loginData;

      if(data['encryptedLoginAttempt'] != null) {
        Uint8List decryptedLoginAttempt = await decrypt(data['encryptedLoginAttempt'], await getPublicKey(), await getPrivateKey());
        data['encryptedLoginAttempt'] = new String.fromCharCodes(decryptedLoginAttempt);

        var decryptedLoginAttemptMap = jsonDecode(data['encryptedLoginAttempt']);

        decryptedLoginAttemptMap['type'] = data['type'];
        decryptedLoginAttemptMap['created'] = data['created'];

        loginData = Login.fromJson(decryptedLoginAttemptMap);
      } else {
        loginData = Login.fromJson(data);
      }
      
      loginData.isMobile = false;
      print('[login]: Decrypted data');
      print(data);

      loginData.loginId = randomString(10);

      // We need home_screen's context to continue ... I feel like this could be done more efficiently. 
      Events().emit(NewLoginEvent(loginData: loginData, loginId: loginData.loginId));
    });

    socket.on('disconnect', (_) {
      print('disconnect');
    });

    socket.on('fromServer', (_) => print(_));
    socket.on('connect_error', (err) => print(err));
    Events().onEvent(CloseSocketEvent().runtimeType, closeSocketConnection);
  }

  void closeSocketConnection(CloseSocketEvent event) {
    print('closing socket connection....');
    socket.emit('leave', {'room': doubleName});
    socket.clearListeners();
    socket.disconnect();
    socket.close();
    socket.destroy();
  }

  void joinRoom(roomName) {
    print('joining room....' + roomName);
    socket.emit('join', {'room': roomName, 'app': true});
  }

  void leaveRoom(roomName) {
    print('Leaving room....' + roomName);
    socket.emit('leave', {'room': roomName});
  }
}

Future openLogin(BuildContext context, Login loginData, BackendConnection backendConnection) async {
  String messageType = loginData.type;

  if (messageType == 'login' && !loginData.isMobile) {
    String pin = await getPin();

    Events().emit(CloseAuthEvent(close: true));

    bool authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
            correctPin: pin, userMessage: "sign your attempt.", loginData: loginData),
      ),
    );

    if (authenticated != null && authenticated) {
      backendConnection.leaveRoom(loginData.doubleName);
      backendConnection.joinRoom(loginData.signedRoom);

      bool loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(loginData),
        ),
      );

      if (loggedIn != null && loggedIn) {
        backendConnection.leaveRoom(loginData.signedRoom);
        backendConnection.joinRoom(loginData.doubleName);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessfulScreen(
                title: "Logged in",
                text: "You are now logged in. Return to browser."),
          ),
        );
      } else {
        backendConnection.leaveRoom(loginData.signedRoom);
        backendConnection.joinRoom(loginData.doubleName);
      }
    }
  } else if (messageType == 'email_verification') {
    getEmail().then((email) async {
      if (email['email'] != null) {
        String tmpDoubleName = (await getDoubleName()).toLowerCase();

        getSignedEmailIdentifierFromOpenKYC(tmpDoubleName)
            .then((response) async {
          Map<String, dynamic> body = jsonDecode(response.body);

          dynamic signedEmailIdentifier = body["signed_email_identifier"];

          if (signedEmailIdentifier != null &&
              signedEmailIdentifier.isNotEmpty) {
            Map<String, dynamic> vsei = jsonDecode(
                (await verifySignedEmailIdentifier(signedEmailIdentifier))
                    .body);

            if (vsei != null &&
                vsei["email"] == email["email"] &&
                vsei["identifier"] == tmpDoubleName) {
              await saveEmail(vsei["email"], signedEmailIdentifier);

              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  image: Icons.email,
                  title: "Email verified",
                  description: new Text("Your email has been verified!"),
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
        });
      }
    });
  }
}
