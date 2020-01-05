import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/screens/ChangePinScreen.dart';
import 'package:threebotlogin/screens/MobileRegistrationScreen.dart';
import 'package:threebotlogin/screens/RecoverScreen.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

class UnregisteredScreen extends StatefulWidget {
  UnregisteredScreen();

  _UnregisteredScreenState createState() => _UnregisteredScreenState();
}

class _UnregisteredScreenState extends State<UnregisteredScreen>
    with WidgetsBindingObserver {
  _UnregisteredScreenState();

  Future<void> startRegistration() async {
    final bool registered = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => MobileRegistrationScreen()));

    if (registered != null && registered) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChangePinScreen(hideBackButton: true)));
     /* CustomDialog(
          title: "Registered", description: Text("You are now registered.")).show(context);*/
      Navigator.pop(context);
    }
  }

  Future<void> startRecovery() async {
    final bool registered = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => RecoverScreen()));
    if (registered != null && registered) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChangePinScreen(hideBackButton: true)));
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SuccessfulScreen(
                  title: "Registered", text: "You are now registered.")));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
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
                    width: 200.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/logo.png')),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/newLogo.png',
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Bot Connect",
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Welcome to 3Bot Connect.',
                        style: TextStyle(fontSize: 24, color: Colors.black)),
                    SizedBox(height: 10),
                    RaisedButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30),
                      ),
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Icon(
                            CommunityMaterialIcons.account_edit,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Register now',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () {
                        startRegistration();
                      },
                    ),
                    RaisedButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30),
                      ),
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Icon(
                            CommunityMaterialIcons.backup_restore,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Recover account',
                            style: TextStyle(color: Colors.white),
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
    );
  }
}
