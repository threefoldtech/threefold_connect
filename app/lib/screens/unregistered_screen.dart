//import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/flags.dart';
import 'package:threebotlogin/screens/change_pin_screen.dart';
import 'package:threebotlogin/screens/mobile_registration_screen.dart';
import 'package:threebotlogin/screens/recover_screen.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/home_logo.dart';

class UnregisteredScreen extends StatefulWidget {
  const UnregisteredScreen({super.key});

  @override
  State<UnregisteredScreen> createState() => _UnregisteredScreenState();
}

class _UnregisteredScreenState extends State<UnregisteredScreen>
    with WidgetsBindingObserver {
  _UnregisteredScreenState();

  Future<void> startRegistration() async {
    final bool? registered = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MobileRegistrationScreen()));

    if (registered != null && registered) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const ChangePinScreen(hideBackButton: true)));
      /* CustomDialog(
          title: "Registered", description: Text("You are now registered.")).show(context);*/
      Navigator.pop(context, true);
    }
  }

  Future<void> startRecovery() async {
    final bool? registered = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RecoverScreen()));
    if (registered != null && registered) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const ChangePinScreen(hideBackButton: true)));

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => const CustomDialog(
          image: Icons.check,
          title: 'Recovered',
          description: 'Your account has been recovered.',
        ),
      );
      await Future.delayed(
        const Duration(seconds: 3),
        () {
          Navigator.pop(context);
        },
      );
      Navigator.pop(context);

      await Flags().initFlagSmith();
      await Flags().setFlagSmithDefaultValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Hero(
              tag: 'logo',
              child: HomeLogoWidget(
                animate: false,
              ),
            ),
            const SizedBox(height: 150),
            SizedBox(
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Sign Up',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                        ),
                      ],
                    ),
                    onPressed: () {
                      startRegistration();
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Recover Account',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                        ),
                      ],
                    ),
                    onPressed: () {
                      startRecovery();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
