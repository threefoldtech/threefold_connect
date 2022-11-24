import 'package:flutter/material.dart';
import 'package:threebotlogin/core/auth/pin/helpers/pin.helpers.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/sign/classes/sign.classes.dart';
import 'package:threebotlogin/sign/dialogs/sign.dialogs.dart';
import 'package:threebotlogin/sign/views/sign.screen.dart';
import 'package:threebotlogin/sockets/enums/socket.enums.dart';

Future<void> openSign(Sign signData) async {
  String? messageType = signData.type;

  if (messageType == null || messageType != SocketListenerTypes.sign) {
    return;
  }

  bool? authenticated = await authenticateYourself();
  if (authenticated == null || !authenticated) {
    return;
  }

  bool? loggedIn = await Navigator.push(
    Globals().globalBuildContext,
    MaterialPageRoute(
      builder: (context) => SignScreen(signData),
    ),
  );

  if (loggedIn == null || !loggedIn) return;

  await showSignedInDialog();
}
