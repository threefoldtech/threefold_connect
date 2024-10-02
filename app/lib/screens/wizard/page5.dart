import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:threebotlogin/screens/main_screen.dart';
import 'package:threebotlogin/screens/wizard/web_view.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/wizard/terms_agreement.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.height * 0.25,
              child: SvgPicture.asset(
                'assets/journey.svg',
                alignment: Alignment.center,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Column(children: [
              Text(
                'STARTYOUR',
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'THREEFOLD',
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'JOURNEY',
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () async {
                      final termsAgreement =
                          Provider.of<TermsAgreement>(context, listen: false);
                      if (!termsAgreement.isChecked) {
                        termsAgreement.attemptToContinue();
                      } else {
                        saveInitDone();
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MainScreen(
                                  initDone: true,
                                  registered: false,
                                )));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      'GET STARTED',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary),
                    )),
              ),
              Consumer<TermsAgreement>(
                  builder: (context, termsAgreement, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: termsAgreement.isChecked,
                      onChanged: (bool? value) {
                        termsAgreement.toggleChecked(value ?? false);
                      },
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "I agree to Threefold's ",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: termsAgreement
                                              .attemptedWithoutAccepting &&
                                          !termsAgreement.isChecked
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                ),
                          ),
                          TextSpan(
                            text: 'Terms and conditions.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: termsAgreement
                                              .attemptedWithoutAccepting &&
                                          !termsAgreement.isChecked
                                      ? Theme.of(context).colorScheme.error
                                      : Colors.blue,
                                  decoration: TextDecoration.underline,
                                  decorationColor: termsAgreement
                                              .attemptedWithoutAccepting &&
                                          !termsAgreement.isChecked
                                      ? Theme.of(context).colorScheme.error
                                      : Colors.blue,
                                ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const WebView()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              })
            ])
          ],
        ),
      ),
    );
  }
}
