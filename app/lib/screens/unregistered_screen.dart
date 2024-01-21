//import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/helpers/flags.dart';
import 'package:threebotlogin/screens/change_pin_screen.dart';
import 'package:threebotlogin/screens/mobile_registration_screen.dart';
import 'package:threebotlogin/screens/recover_screen.dart';
import 'package:threebotlogin/screens/successful_screen.dart';

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

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const SuccessfulScreen(
                  title: 'Recovered',
                  text: 'Your account has been recovered.')));

      Navigator.pop(context);

      await Flags().initFlagSmith();
      await Flags().setFlagSmithDefaultValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      body: Stack(
        children: <Widget>[
          SvgPicture.asset(
            'assets/bg.svg',
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
                BlendMode.srcIn),
          ),
          WillPopScope(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxHeight: double.infinity,
                  maxWidth: double.infinity,
                  minHeight: 250,
                  minWidth: 250),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 300.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.onBackground,
                                  BlendMode.srcIn),
                              fit: BoxFit.fill,
                              image: const AssetImage('assets/logoTF.png')),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
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
            onWillPop: () {
              return Future.value(false);
            },
          ),
        ],
      ),
    ));
  }
}
