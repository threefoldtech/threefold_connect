import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:threebotlogin/screens/wizard/web_view.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/wizard/terms_agreement.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
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
                  MaterialPageRoute(builder: (context) => const WebView()),
                );
              },
              child: Text('Terms & Conditions',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue)),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Consumer<TermsAgreement>(builder: (context, termsAgreement, child) {
              return Row(
                children: [
                  Checkbox(
                    value: termsAgreement.isChecked,
                    onChanged: (bool? value) {
                      termsAgreement.toggleChecked(value ?? false);
                    },
                  ),
                  Expanded(
                    child: Text('I Accept the Terms & Conditions.',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: termsAgreement.attemptedWithoutAccepting &&
                                    !termsAgreement.isChecked
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.onSurface)),
                  ),
                ],
              );
            })
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final termsAgreement =
                Provider.of<TermsAgreement>(context, listen: false);
            if (!termsAgreement.isChecked) {
              termsAgreement.attemptToContinue();
            } else {
              saveInitDone();
              Navigator.of(context).pop();
              Navigator.pop(context, true);
            }
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
