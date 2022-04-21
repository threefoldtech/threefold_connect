import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class RegisteredScreen extends StatefulWidget {
  static final RegisteredScreen _singleton = new RegisteredScreen._internal();

  factory RegisteredScreen() {
    return _singleton;
  }

  RegisteredScreen._internal() {
    //init
  }

  _RegisteredScreenState createState() => _RegisteredScreenState();
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
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 300.0,
                    height: 90.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/logo.png')),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: 200.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/threefold_registered.png')),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.75,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: 'Welcome to the\n'),
                            new TextSpan(
                                text: 'ThreeFold Connect App! \n',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(text: 'Click on the '),
                            new TextSpan(
                                text: 'menu ',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(text: 'icon \n to get started'),
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
      this.showPreference = preference;
    });
  }
}
