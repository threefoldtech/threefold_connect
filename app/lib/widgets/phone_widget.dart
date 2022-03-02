import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/phone_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

import 'custom_dialog.dart';



Future<void> addPhoneNumberDialog(context) async {
  Response res = await getCountry();
  var countryCode = res.body.replaceAll("\n", "");

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => PhoneAlertDialog(defaultCountryCode: countryCode),
  );
}

phoneSendDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) =>
        CustomDialog(
          image: Icons.check,
          title: "Sms has been sent.",
          description: "A verification sms has been sent.",
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

class PhoneAlertDialog extends StatefulWidget {
  final String defaultCountryCode;

  const PhoneAlertDialog({Key? key, required this.defaultCountryCode}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new PhoneAlertDialogState();
  }
}

class PhoneAlertDialogState extends State<PhoneAlertDialog> {
  bool valid = false;
  String verificationPhoneNumber = '';

  @override
  void initState() {
    valid = false;
    verificationPhoneNumber = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
        image: Icons.phone,
        title: "Add phone number",
        widgetDescription: SizedBox(
          height: 100,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IntlPhoneField(
                    initialCountryCode: widget.defaultCountryCode,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    onChanged: (phone) {
                      PhoneNumber p = phone;
                      print(p.completeNumber);

                      RegExp regExp = new RegExp(
                        r"^(\+[0-9]{1,3}|0)[0-9]{3}( ){0,1}[0-9]{7,8}\b$",
                        caseSensitive: false,
                        multiLine: false,
                      );

                      setState(() {
                        valid = regExp.hasMatch(p.completeNumber.replaceAll('\n', ''));
                        verificationPhoneNumber = p.completeNumber;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              color: valid ? Theme.of(context).primaryColor : Colors.grey,
              child: valid
                  ? const Text('Add', style: const TextStyle(color: Colors.white))
                  : const Text('Ok', style: const TextStyle(color: Colors.black)),
              onPressed: verifyButton)
        ]);
  }

  Future<dynamic> wantToVerifyNow() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => CustomDialog(
        image: Icons.info,
        title: "Verify phone number",
        description: "Do you want to verify your phone number now?",
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: Text('No')),
          FlatButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                await sendPhoneVerification();
              },
              child: Text('Yes'))
        ],
      ),
    );
  }
  void verifyButton() async {
    if (!valid) {
      return;
    }

    savePhone(verificationPhoneNumber, null);

    FlutterPkid client = await getPkidClient();
    client.setPKidDoc('phone', json.encode({'phone': verificationPhoneNumber}));

    wantToVerifyNow();
  }

  sendPhoneVerification() async {
    int currentTime = new DateTime.now().millisecondsSinceEpoch;

    if (Globals().tooManySmsAttempts && Globals().lockedSmsUntill > currentTime) {
      Globals().sendSmsAttempts = 0;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Too many attempts please wait ' +
                ((Globals().lockedSmsUntill - currentTime) / 1000).round().toString() +
                ' seconds.'),
            actions: <Widget>[
              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    Globals().tooManySmsAttempts = false;

    if (Globals().sendSmsAttempts >= 3) {
      Globals().tooManySmsAttempts = true;
      Globals().lockedSmsUntill = currentTime + 60000;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Too many attempts please wait one minute.'),
            actions: <Widget>[
              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    Globals().sendSmsAttempts++;

    sendVerificationSms();

    Globals().hidePhoneButton.value = true;
    Globals().smsSentOn = new DateTime.now().millisecondsSinceEpoch;

    phoneSendDialog(context);

    Navigator.pop(context);
  }
}
