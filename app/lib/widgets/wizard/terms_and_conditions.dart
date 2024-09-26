import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:threebotlogin/screens/unregistered_screen.dart';
import 'package:threebotlogin/screens/wizard/web_view.dart';
import 'package:threebotlogin/widgets/wizard/terms_agreement.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Accept the terms and conditions?',
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'Before you can start using the app, you must accept the Terms and Conditions.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WebView()),
                );
              },
              child: const Text(
                'Terms and Conditions',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
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
                    child: Text('I Accept the terms and conditions.',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground)),
                  ),
                ],
              );
            })
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (Provider.of<TermsAgreement>(context, listen: false).isChecked) {
              Navigator.of(context).pop();
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UnregisteredScreen()));
            }
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
