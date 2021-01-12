import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

emailVerificationDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
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

phoneSendDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.check,
      title: "Sms has been sent.",
      description: "An verification sms has been sent.",
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


addPhoneNumberDialog(context) async {
  var phoneIsoCode;
  bool valid = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => PhoneAlertDialog(),
  );
  
  print('tset');
}

class PhoneAlertDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PhoneAlertDialogState();
  }
}

class PhoneAlertDialogState extends State<PhoneAlertDialog> {
  bool valid = false;
  String phoneNumber = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        // image: Icons.check,
        // title: "Add your phone number",
        // description: "A valid phone number and an verification sms will be send`.",
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: InternationalPhoneInputText(
                onValidPhoneNumber: (String number,
                        String internationalizedPhoneNumber, String isoCode) =>
                    {

                  setState(() {
                    phoneNumber = internationalizedPhoneNumber;
                    valid = true;
                  })
                },
                labelText: "Phone Number",
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          new RaisedButton(
              color: valid ? Colors.green : Colors.grey,
              child: const Text('VERIFY'),
              onPressed: () {
                savePhone(phoneNumber, null);
                Navigator.pop(context);
              })
        ]);
  }
}

void onPhoneNumberChange(
    String phoneNumber, String internationalizedPhoneNumber, String isoCode) {}

onValidPhoneNumber(
    String number, String internationalizedPhoneNumber, String isoCode) {}
