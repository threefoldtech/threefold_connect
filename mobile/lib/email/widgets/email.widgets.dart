import 'package:flutter/material.dart';
import 'package:threebotlogin/core/components/dialogs/custom.dialog.core.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

Future<void> showSuccessEmailVerifiedDialog() {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.email,
      title: "Email verified",
      description: "Your email has been verified!",
      actions: <Widget>[
        TextButton(child: new Text("Ok"), onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}

Future<void> showFailedEmailVerifiedDialog() {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.warning,
      title: "Couldn't verify email",
      description: "Your email couldn't be verified",
      actions: <Widget>[
        TextButton(child: new Text("Ok"), onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}
