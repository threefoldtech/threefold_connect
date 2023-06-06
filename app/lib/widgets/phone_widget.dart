import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/phone_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

import 'custom_dialog.dart';

Future<void> addPhoneNumberDialog(context) async {
  Response res = await getCountry();
  var countryCode = res.body.replaceAll('\n', '');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) =>
        PhoneAlertDialog(defaultCountryCode: countryCode),
  );
}

phoneSendDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.check,
      title: 'Sms has been sent.',
      description: 'A verification sms has been sent.',
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
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

  const PhoneAlertDialog({Key? key, required this.defaultCountryCode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PhoneAlertDialogState();
  }
}

class PhoneAlertDialogState extends State<PhoneAlertDialog> {
  bool valid = false;
  String verificationPhoneNumber = '';

  @override
  void initState() {
    valid = false;
    verificationPhoneNumber = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
        image: Icons.phone,
        title: 'Add phone number',
        widgetDescription: SizedBox(
          height: 100,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IntlPhoneField(
                    initialCountryCode: widget.defaultCountryCode,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    onChanged: (phone) {
                      PhoneNumber p = phone;
                      RegExp regExp = RegExp(
                        r'^(\+[0-9]{1,3}|0)[0-9]{3}( ){0,1}[0-9]{7,8}\b$',
                        caseSensitive: false,
                        multiLine: false,
                      );

                      setState(() {
                        valid = regExp
                            .hasMatch(p.completeNumber.replaceAll('\n', ''));
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
          TextButton(
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          TextButton(
              style: ButtonStyle(
                foregroundColor: valid
                    ? MaterialStateProperty.all(Theme.of(context).primaryColor)
                    : MaterialStateProperty.all(Colors.grey),
              ),
              onPressed: verifyButton,
              child: valid
                  ? const Text('Add', style: TextStyle(color: Colors.white))
                  : const Text('Ok', style: TextStyle(color: Colors.black)))
        ]);
  }

  Future<dynamic> wantToVerifyNow() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => CustomDialog(
        image: Icons.info,
        title: 'Verify phone number',
        description: 'Do you want to verify your phone number now?',
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('No')),
          TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                await sendPhoneVerification();
              },
              child: const Text('Yes'))
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
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (Globals().tooManySmsAttempts &&
        Globals().lockedSmsUntil > currentTime) {
      Globals().sendSmsAttempts = 0;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                'Too many attempts please wait ${((Globals().lockedSmsUntil - currentTime) / 1000).round()} seconds.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
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
      Globals().lockedSmsUntil = currentTime + 60000;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Too many attempts please wait one minute.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
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
    Globals().smsSentOn = DateTime.now().millisecondsSinceEpoch;

    phoneSendDialog(context);

    Navigator.pop(context);
  }
}
