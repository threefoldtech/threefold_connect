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
                        width: 360.0,
                        height: 108.0,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/logo.png')),
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
                                Theme.of(context).colorScheme.secondary,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'SIGN UP',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
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
                                Theme.of(context).colorScheme.secondary,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'RECOVER ACCOUNT',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
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
