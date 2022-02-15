import 'package:flutter/material.dart';

import 'custom_dialog.dart';

Future<void> showExpiredDialog(BuildContext ctx) async {
  return await showDialog(
    context: ctx,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.timer,
      title: 'Login attempt expired',
      description: 'Your login attempt has expired, please request a new one in your browser.',
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}

Future<void> showWrongEmojiDialog(BuildContext ctx) async {
   await showDialog(
    context: ctx,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.warning,
      title: 'Wrong emoji',
      description: 'You selected the wrong emoji, please check your browser for the new one.',
      actions: <Widget>[
        FlatButton(
          child: Text('Retry'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}

Future<void> showLoggedInDialog(BuildContext ctx) async {
  await showDialog(
    context: ctx,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.check,
      title: 'Logged in',
      description: 'You are now logged in. Please return to your browser.',
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}

Future<void> showSignedInDialog(BuildContext ctx) async {
  await showDialog(
    context: ctx,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.check,
      title: 'Successfully signed',
      description: 'The data has been successfully signed. Please return to your browser.',
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}
