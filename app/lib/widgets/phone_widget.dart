import 'package:flutter/material.dart';
import 'package:intl_mobile_field/countries.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:threebotlogin/services/phone_service.dart';

import 'custom_dialog.dart';

Future<void> addPhoneNumberDialog(context,
    {required bool newPhone,
    required String oldPhone,
    required Function onVerify}) async {
  final countryCode = await getCountry();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => PhoneAlertDialog(
        defaultCountryCode: countryCode,
        newPhone: newPhone,
        oldPhone: oldPhone,
        onVerify: onVerify,),
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
  final Function onVerify;

  const PhoneAlertDialog(
      {super.key,
      required this.defaultCountryCode,
      required this.newPhone,
      required this.oldPhone,
      required this.onVerify});

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
                'Changing your phone will require re-\u200dverification',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          if (!widget.newPhone) const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IntlMobileField(
              initialCountryCode: widget.defaultCountryCode,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
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
                final isValid = phone != null &&
                    phone.completeNumber != widget.oldPhone &&
                    phone.number.length >= _country.minLength &&
                    phone.number.length <= _country.maxLength;

                setState(() => valid = isValid);
                verificationPhoneNumber = isValid ? phone.completeNumber : '';

                return isValid
                    ? null
                    : (phone!.completeNumber == widget.oldPhone
                        ? 'Please enter a different number'
                        : 'Invalid Mobile Number');
              },
              disableLengthCheck: true,
              onCountryChanged: (country) {
                if (_country != country) valid = false;
                _country = country;
                setState(() {});
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        if (valid)
          TextButton(
            onPressed: () async{
              await widget.onVerify(valid, verificationPhoneNumber);
              Navigator.pop(context);
            },
            child: Text(widget.newPhone ? 'Add' : 'Update'),
          ),
      ],
    );
  }
}
