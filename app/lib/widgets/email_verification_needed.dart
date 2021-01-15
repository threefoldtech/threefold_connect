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
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => PhoneAlertDialog(),
  );
}

class PhoneAlertDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PhoneAlertDialogState();
  }
}

class PhoneAlertDialogState extends State<PhoneAlertDialog> {
  bool valid;
  String verificationPhoneNumber;

  @override
  void initState() {
    valid = false;
    verificationPhoneNumber = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: SizedBox(
          height: 100,
          child: Row(
            children: <Widget>[
              Expanded(
                child: InternationalPhoneInput(
                  // initialSelection: initial ? initial['phoneCode'] : '',
                  onPhoneNumberChange: onNumberChange,
                  labelText: "Phone Number",
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          new RaisedButton(
              color: valid ? Colors.green : Colors.grey,
              child: const Text('VERIFY'),
              onPressed: verifyButton)
        ]);
  }

  void verifyButton() {
    if (!valid) {
      return;
    }
    savePhone(verificationPhoneNumber, null);
    Navigator.pop(context);
  }

  void onNumberChange(
      String phoneNumber, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      valid = internationalizedPhoneNumber.isNotEmpty;
      verificationPhoneNumber = internationalizedPhoneNumber;
    });
  }
}

void onPhoneNumberChange(
    String phoneNumber, String internationalizedPhoneNumber, String isoCode) {}

onValidPhoneNumber(
    String number, String internationalizedPhoneNumber, String isoCode) {}
