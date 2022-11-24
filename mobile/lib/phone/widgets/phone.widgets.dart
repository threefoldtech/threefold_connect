import 'package:flutter/material.dart';
import 'package:threebotlogin/core/components/dialogs/custom.dialog.core.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

Future<void> showSuccessPhoneVerifiedDialog() {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.phone,
      title: "Phone verified",
      description: "Your phone has been verified!",
      actions: <Widget>[
        TextButton(child: new Text("Ok"), onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}

Future<void> showFailedPhoneVerifiedDialog() {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.warning,
      title: "Couldn't verify phone",
      description: "Your phone couldn't be verified",
      actions: <Widget>[
        TextButton(child: new Text("Ok"), onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}
