import 'package:flutter/material.dart';
import 'package:threebotlogin/core/components/dialogs/custom.dialog.core.dart';
import 'package:threebotlogin/core/storage/auth/auth.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

Future<void> showIncorrectPin() {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.warning,
      title: "Incorrect PIN",
      description: "Your PIN is incorrect",
      actions: <Widget>[
        TextButton(child: new Text("Ok"), onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}

Future<void> showTooManyAttempts() async {
  int lockedUntil = await getLockedUntil();
  int currentTime = new DateTime.now().millisecondsSinceEpoch;

  String seconds = ((lockedUntil - currentTime) / 1000).toStringAsFixed(0);

  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.warning,
      title: "Too many attempts",
      description: "Too many incorrect attempts, please wait $seconds seconds",
      actions: <Widget>[
        TextButton(child: new Text("Ok"), onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}
