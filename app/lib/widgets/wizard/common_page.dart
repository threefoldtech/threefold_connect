import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/screens/wizard/web_view.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class CommonPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String? description;
  final double? heightPercentage;
  final double? widthPercentage;
  final bool? showTermsAndConditions;

  const CommonPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.description = '',
    this.heightPercentage = 100,
    this.widthPercentage = 300,
    this.showTermsAndConditions = false,
  }) : super(key: key);

  @override
  State<CommonPage> createState() => _CommonPageState();
}

class _CommonPageState extends State<CommonPage> {
  bool agreed = false;
  bool attemptToContinue = false;
  final termsAndConditionsUrl = Globals().termsAndConditionsUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.9,
              child: Column(children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: widget.title == 'WELCOME TO'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (widget.subtitle.isNotEmpty)
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                SizedBox(
                  height: widget.subtitle.isEmpty
                      ? MediaQuery.of(context).size.height * 0.15
                      : MediaQuery.of(context).size.height * 0.04,
                ),
                widget.imagePath.endsWith('.svg')
                    ? SvgPicture.asset(
                        widget.imagePath,
                        alignment: Alignment.center,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurface,
                          BlendMode.srcIn,
                        ),
                        width: widget.widthPercentage != null
                            ? MediaQuery.of(context).size.width *
                                widget.widthPercentage!
                            : null,
                        height: widget.heightPercentage != null
                            ? MediaQuery.of(context).size.width *
                                widget.heightPercentage!
                            : null,
                      )
                    : Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                        width: widget.widthPercentage != null
                            ? MediaQuery.of(context).size.width *
                                widget.widthPercentage!
                            : null,
                        height: widget.heightPercentage != null
                            ? MediaQuery.of(context).size.width *
                                widget.heightPercentage!
                            : null,
                      ),
              ]),
            ),
            if (widget.description!.isNotEmpty)
              SizedBox(
                width: MediaQuery.of(context).size.width - 100,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Text(
                  widget.description!,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (widget.showTermsAndConditions!)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (agreed) {
                          saveInitDone();
                          Navigator.pop(context, true);
                        }
                        attemptToContinue = true;
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        "Let's Go",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: agreed,
                        onChanged: (bool? value) {
                          agreed = value ?? false;
                          setState(() {});
                        },
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "I agree to ThreeFolds' ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: !agreed && attemptToContinue
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                            ),
                            TextSpan(
                              text: 'Terms & Conditions.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: !agreed && attemptToContinue
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: !agreed &&
                                            attemptToContinue
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.blue,
                                  ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WebView(
                                              title: 'Terms and Conditions',
                                              url: termsAndConditionsUrl,
                                            )),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
