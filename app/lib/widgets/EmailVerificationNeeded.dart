import 'package:flutter/material.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

emailVerificationDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.error,
      title: "Please verify email",
      description: new Text("Please verify email before using this app"),
      actions: <Widget>[
        FlatButton(
          child: new Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: new Text("Resend email"),
          onPressed: () async {
            sendVerificationEmail();
            Navigator.pop(context);
            emailResendedDialog(context);
          },
        ),
      ],
    ),
  );
}

emailResendedDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.check,
      title: "Email has been resent.",
      description: new Text("A new verification email has been sent."),
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
}
