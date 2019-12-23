import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:threebotlogin/services/userService.dart';
import 'dart:convert';
import 'dart:io';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/WebviewService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

IO.Socket socket;
BuildContext ctx;
bool conntected = false;

String threeBotSocketUrl = config.threeBotSocketUrl;

createSocketConnection(BuildContext context, String doubleName) async {
  if (conntected) return;
  ctx = context;

  if (doubleName == null) {
    doubleName = await getDoubleName();
  }

  print('creating socket conncetion....');
  socket = IO.io(threeBotSocketUrl, <String, dynamic>{
    'transports': ['websocket']
  });

  socket.on('connect', (res) {
    print('connected');
    // If a doubleName already exists/provided join room with this doublename
    if (doubleName != null) {
      print('joining room....');
      // once a client has connected, we let him join a room
      socket.emit('join', { 'room': doubleName });
    }
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
    conntected = false;
  });

  socket.on('fromServer', (_) => print(_));
  socket.on('connect_error', (err) => print(err));
}

void closeSocketConnection(String doubleName) {
  print('closing socket connection....');
  socket.emit('leave', { 'room': doubleName });
  socket.close();
}

void joinRoom(String doubleName) {
  print('joining room....');
  socket.emit('join', { 'room': doubleName });
}

void socketLoginMobile(Map<String, dynamic> data) {
  print('loging in');
  return socket.emit('login', data);
}

Future openLogin(context, data) async {
  if (Platform.isIOS) {
    data = data;
  }

  logger.log(data);

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