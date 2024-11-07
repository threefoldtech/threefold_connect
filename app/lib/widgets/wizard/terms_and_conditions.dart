import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/wizard/web_view.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/helpers/globals.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  bool agreed = false;
  bool attemptToContinue = false;
  final termsAndConditionsUrl = Globals().termsAndConditionsUrl;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Accept the Terms and Conditions?',
      widgetDescription: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Before you can start using the app, you must accept the Terms and Conditions.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WebView(url: termsAndConditionsUrl, title: 'Terms and Conditions', )),
                );
              },
              child: Text('Terms & Conditions',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue)),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              children: [
                Checkbox(
                  value: agreed,
                  onChanged: (bool? value) {
                    agreed = value ?? false;
                    setState(() {});
                  },
                ),
                Expanded(
                  child: Text('I Accept the terms and conditions.',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: !agreed && attemptToContinue
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.onSurface)),
                ),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (agreed) {
              saveInitDone();
              Navigator.of(context).pop();
              Navigator.pop(context, true);
            }
            attemptToContinue = true;
            setState(() {});
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
