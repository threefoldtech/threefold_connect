import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class RegisteredScreen extends StatefulWidget {
  static final RegisteredScreen _singleton = RegisteredScreen._internal();

  factory RegisteredScreen() {
    return _singleton;
  }

  RegisteredScreen._internal() {
    //init
  }

  @override
  State<RegisteredScreen> createState() => _RegisteredScreenState();
}

class _RegisteredScreenState extends State<RegisteredScreen>
    with WidgetsBindingObserver {
  // We will treat this error as a singleton

  bool showSettings = false;
  bool showPreference = false;

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
        titleText: 'Home',
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 250.0,
                    height: 28.33,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                         colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.onBackground,
                                  BlendMode.srcIn),
                          fit: BoxFit.fill,
                          image: const AssetImage('assets/logoTF.png')),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    width: 200.0,
                    height: 200.0,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/threefold_registered.png')),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.75,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          children: const <TextSpan>[
                            TextSpan(text: 'Welcome to the\n'),
                            TextSpan(
                                text: 'ThreeFold Connect App! \n',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: 'Click on the '),
                            TextSpan(
                                text: 'menu ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: 'icon \n to get started'),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  void updatePreference(bool preference) {
    setState(() {
      showPreference = preference;
    });
  }
}
