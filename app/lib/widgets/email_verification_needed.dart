import 'package:flutter/material.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

emailVerificationDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) =>
        CustomDialog(
          image: Icons.error,
          title: "Please verify email",
          description: "Please verify email before using this app",
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
                emailResentDialog(context);
              },
            ),
          ],
        ),
  );
}

emailResentDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) =>
        CustomDialog(
          image: Icons.check,
          title: "Email has been resent.",
          description: "A new verification email has been sent.",
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