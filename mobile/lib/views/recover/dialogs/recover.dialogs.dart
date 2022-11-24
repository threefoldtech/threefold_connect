import 'package:flutter/material.dart';
import 'package:threebotlogin/core/components/dialogs/custom.dialog.core.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

Future<void> showSuccessfullyRecovered() {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.verified,
      title: "Recovered",
      description: "Your account has successfully been recovered!",
      actions: <Widget>[
        TextButton(child: new Text("Ok"), onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}
