import 'package:flutter/material.dart';
import 'package:threebotlogin/core/components/dialogs/custom.dialog.core.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

Future<void> showRegistrationFailedDialog() {
  return showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.error,
      title: 'Error',
      description: 'Something went wrong when trying to create your account.',
      actions: <Widget>[
        TextButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}
