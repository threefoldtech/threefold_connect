import 'package:flutter/material.dart';
import 'package:threebotlogin/core/components/dialogs/custom.dialog.core.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

Future<void> showExpiredDialog() async {
  return await showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.timer,
      title: 'Login attempt expired',
      description: 'Your login attempt has expired, please request a new one in your browser.',
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

Future<void> showWrongEmojiDialog() async {
  return await showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.warning,
      title: 'Wrong emoji',
      description: 'You selected the wrong emoji, please check your browser for the new one.',
      actions: <Widget>[
        TextButton(
          child: Text('Retry'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}

Future<void> showSomethingWentWrongDialog() async {
  return await showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.warning,
      title: 'Something went wrong',
      description: 'Something went wrong initializing the login attempt, please contact support',
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

Future<void> showLoggedInDialog() async {
  return await showDialog(
    context: Globals().globalBuildContext,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.check,
      title: 'Logged in',
      description: 'You are now logged in. Please return to your browser.',
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
