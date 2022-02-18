//import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/helpers/flags.dart';
import 'package:threebotlogin/screens/change_pin_screen.dart';
import 'package:threebotlogin/screens/mobile_registration_screen.dart';
import 'package:threebotlogin/screens/recover_screen.dart';
import 'package:threebotlogin/screens/successful_screen.dart';

class UnregisteredScreen extends StatefulWidget {
  UnregisteredScreen();

  _UnregisteredScreenState createState() => _UnregisteredScreenState();
}

class _UnregisteredScreenState extends State<UnregisteredScreen>
    with WidgetsBindingObserver {
  _UnregisteredScreenState();

  Future<void> startRegistration() async {
    final bool? registered = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => MobileRegistrationScreen()));

    if (registered != null && registered) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChangePinScreen(hideBackButton: true)));
      /* CustomDialog(
          title: "Registered", description: Text("You are now registered.")).show(context);*/
      Navigator.pop(context, true);
    }
  }

  Future<void> startRecovery() async {
    final bool? registered = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => RecoverScreen()));
    if (registered != null && registered) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChangePinScreen(hideBackButton: true)));

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SuccessfulScreen(
                      title: "Recovered",
                      text: "Your account has been recovered.")));

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
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
              ),
              Container(
                child: WillPopScope(
                  child: Container(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                          maxWidth: double.infinity,
                          minHeight: 250,
                          minWidth: 250),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 360.0,
                                height: 108.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage('assets/logo.png')),
                                ),
                              ),
                              SizedBox(height: 10.0),
                            ],
                          ),
                          SizedBox(
                            width: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                RaisedButton(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(30),
                                  ),
                                  color: Theme
                                      .of(context)
                                      .accentColor,
                                  child: Row(
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
                                SizedBox(height: 20),
                                RaisedButton(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(30),
                                  ),
                                  color: Theme
                                      .of(context)
                                      .accentColor,
                                  child: Row(
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
                          Container(),
                        ],
                      ),
                    ),
                  ),
                  onWillPop: () {
                    return Future.value(false);
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
