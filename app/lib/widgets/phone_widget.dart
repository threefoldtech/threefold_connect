import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:http/http.dart';
import 'package:intl_mobile_field/countries.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/phone_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

import 'custom_dialog.dart';

Future<void> addPhoneNumberDialog(context,
    {required bool newPhone, required String oldPhone}) async {
  Response res = await getCountry();
  var countryCode = res.body.replaceAll('\n', '');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => PhoneAlertDialog(
        defaultCountryCode: countryCode,
        newPhone: newPhone,
        oldPhone: oldPhone),
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
          child: const Text('Close'),
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
  final bool newPhone;
  final String oldPhone;

  const PhoneAlertDialog(
      {Key? key,
      required this.defaultCountryCode,
      required this.newPhone,
      required this.oldPhone})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PhoneAlertDialogState();
  }
}

class PhoneAlertDialogState extends State<PhoneAlertDialog> {
  bool valid = false;
  String verificationPhoneNumber = '';
  Country _country = countries.firstWhere((element) => element.code == 'US');

  @override
  void initState() {
    valid = false;
    verificationPhoneNumber = '';
    _country = countries
        .firstWhere((element) => element.code == widget.defaultCountryCode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
        image: Icons.phone,
        title: widget.newPhone ? 'Add phone number' : 'Change phone number',
        widgetDescription: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.newPhone)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Changing your phone will require re-verification',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            if (!widget.newPhone)
              const SizedBox(
                height: 30,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntlMobileField(
                initialCountryCode: widget.defaultCountryCode,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
                dropdownTextStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
                validator: (phone) {
                  if (phone!.completeNumber == widget.oldPhone) {
                    setState(() {
                      valid = false;
                    });
                    return 'Please enter a different number';
                  } else if (phone.number.length >= _country.minLength &&
                      phone.number.length <= _country.maxLength) {
                    setState(() {
                      valid = true;
                    });
                    verificationPhoneNumber = phone.completeNumber;
                    return null;
                  } else {
                    setState(() {
                      valid = false;
                    });
                    return 'Invalid Mobile Number';
                  }
                },
                disableLengthCheck: true,
                onCountryChanged: (country) {
                  if (_country != country) {
                    valid = false;
                  }
                  _country = country;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          if (valid)
            TextButton(onPressed: verifyButton, child: const Text('Add'))
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
      if (!mounted) return;
      Globals().sendSmsAttempts = 0;
      showDialog(
        context: context,
        builder: (BuildContext childContext) => CustomDialog(
          image: Icons.info,
          title: 'Too many attempts',
          description:
              'Please wait ${((Globals().lockedSmsUntil - currentTime) / 1000).round()} seconds.',
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(childContext);
              },
            ),
          ],
        ),
      );
      return;
    }

    Globals().tooManySmsAttempts = false;

    if (Globals().sendSmsAttempts >= 3) {
      Globals().tooManySmsAttempts = true;
      Globals().lockedSmsUntil = currentTime + 60000;

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext childContext) => CustomDialog(
          image: Icons.info,
          title: 'Too many attempts',
          description: 'Please wait one minute',
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(childContext);
              },
            ),
          ],
        ),
      );
      return;
    }

    Globals().sendSmsAttempts++;

    sendVerificationSms();

    Globals().hidePhoneButton.value = true;
    Globals().smsSentOn = DateTime.now().millisecondsSinceEpoch;

    if (mounted) {
      phoneSendDialog(context);
      Navigator.pop(context);
    }
  }
}
