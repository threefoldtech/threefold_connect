import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:threebotlogin/Events/Events.dart';
import 'package:threebotlogin/Events/NewLoginEvent.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:threebotlogin/services/userService.dart';
import 'dart:convert';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

import '../AppConfig.dart';

IO.Socket socket;
bool connected = false;

String threeBotSocketUrl = AppConfig().threeBotSocketUrl();

createSocketConnection(BuildContext context) async {
  if (connected) return;

  String doubleName = await getDoubleName();
  if (doubleName == null) {
    print('no doublename is set, not opening socket');
    return;
  }

  print('creating socket connection....');
  socket = IO.io(threeBotSocketUrl, <String, dynamic>{
    'transports': ['websocket']
  });

  socket.on('connect', (res) {
    print('connected');
    // once a client has connected, we let him join a room
    socket.emit('join', {'room': doubleName.toLowerCase(), 'app' : true});
    print('joined room');
    connected = true;
  });

  socket.on('signed', (data) {
    print('---------signed-----------');
    print(data);
  });

  socket.on('login', (data) {
    print('---------login-----------');
    print(data);
    openLogin(context, data);
  });

  socket.on('disconnect', (_) {
    print('disconnect');
    connected = false;
  });

  socket.on('fromServer', (_) => print(_));
  socket.on('connect_error', (err) => print(err));
}

void closeSocketConnection(String doubleName) {
  print('closing socket connection....');
  socket.emit('leave', {'room': doubleName});
  socket.close();
}

void joinRoom(String doubleName) {
  print('joining room....');
  socket.emit('join', {'room': doubleName, 'app': true});
}

void socketLoginMobile(Map<String, dynamic> data) {
  print('loging in');
  return socket.emit('login', data);
}

Future openLogin(context, data) async {
  Events().emit(NewLoginEvent());
  String messageType = data["type"];
  var mobile = data["mobile"];
  var loginToken = data["loginToken"];
  var state = data['state'];
  var publicKey = data['appPublicKey'];
  var scope = data["scope"];
  var appId = data['appId'];

  if (loginToken != null) {
    return await loginFromToken(loginToken, state, publicKey, appId, scope);
  }

  if (messageType == 'login' && mobile != true) {
    var loggedIn = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen(data)));
    if (loggedIn) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SuccessfulScreen(
                  title: "Logged in", text: "You are now logged in.")));
    }
  } else if (messageType == 'email_verification') {
    getEmail().then((email) async {
      if (email['email'] != null) {
        var tmpDoubleName = (await getDoubleName()).toLowerCase();

        getSignedEmailIdentifierFromOpenKYC(tmpDoubleName)
            .then((response) async {
          var body = jsonDecode(response.body);

          var signedEmailIdentifier = body["signed_email_identifier"];

          if (signedEmailIdentifier != null &&
              signedEmailIdentifier.isNotEmpty) {
            var vsei = json.decode(
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

Future<void> loginFromToken(
    String loginToken, String state, String publicKey, String appId, String stringScope) async {
  if (loginToken == await getLoginToken()) {
    var privateKey = getPrivateKey();
    var email = getEmail();
    var keys = getKeys(appId, await getDoubleName());

    var signedHash = signData(state, await privateKey);
    var scope = {};
    var dataToSend;

    if (scope != null) {
      if (stringScope.split(",").contains('user:email')) {
        scope['email'] = await email;
      }

      if (stringScope.split(",").contains('user:keys')) {
        scope['keys'] = await keys;
      }
    }

    if (scope.isNotEmpty) {
      dataToSend =
          await encrypt(jsonEncode(scope), publicKey, await privateKey);
    }
    sendData(state, await signedHash, dataToSend, null);
  }
}
