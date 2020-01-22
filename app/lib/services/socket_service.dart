import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/events/close_socket_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/new_login_event.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/screens/login_screen.dart';
import 'package:threebotlogin/screens/successful_screen.dart';
import 'package:threebotlogin/services/tools_service.dart';
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

    socket.on('signed', (data) {
      print('---------signed-----------');
      print(data);
    });

    socket.on('login', (data) {
      print('---------login-----------');
      print(data);
      data['loginId'] = randomString(10);
      Events().emit(NewLoginEvent(data: data, loginId: data['loginId']));
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

  void joinRoom() {
    print('joining room....');
    socket.emit('join', {'room': doubleName, 'app': true});
  }

  void socketLoginMobile(Map<String, dynamic> data) {
    print('loging in');
    return socket.emit('login', data);
  }
}

Future openLogin(context, data) async {
  String messageType = data["type"];
  var mobile = data["mobile"];

  if (messageType == 'login' && mobile != true) {
    String pin = await getPin();

    bool authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
              correctPin: pin, userMessage: "sign your attempt"),
        ));

    if (authenticated != null && authenticated) {
      bool loggedIn = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen(data)));

      if (loggedIn != null && loggedIn) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessfulScreen(
                  title: "Logged in",
                  text: "You are now logged in. Return to browser."),
            ));
      }
    }
  } else if (messageType == 'email_verification') {
    getEmail().then((email) async {
      if (email['email'] != null) {
        String tmpDoubleName = (await getDoubleName()).toLowerCase();

        getSignedEmailIdentifierFromOpenKYC(tmpDoubleName)
            .then((response) async {
          Map<String, dynamic> body = jsonDecode(response.body);

          //TODO: Check if this always is a string.
          dynamic signedEmailIdentifier = body["signed_email_identifier"];

          if (signedEmailIdentifier != null &&
              signedEmailIdentifier.isNotEmpty) {
            Map<String, dynamic> vsei = json.decode(
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
