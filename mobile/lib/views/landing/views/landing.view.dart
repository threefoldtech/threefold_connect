import 'package:flutter/material.dart';
import 'package:threebotlogin/core/components/dividers/box.dividers.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';
import 'package:threebotlogin/views/recover/views/recover.view.dart';
import 'package:threebotlogin/views/register/views/register.view.dart';

class LandingScreen extends StatefulWidget {
  LandingScreen();

  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with WidgetsBindingObserver {
  _LandingScreenState();

  @override
  Widget build(BuildContext context) {
    Globals().globalBuildContext = context;
    return Material(
        child: Scaffold(
            body: Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [logo()],
              ),
              kSizedBoxXXL,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [registerButton()],
              ),
              kSizedBoxXs,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [recoverButton()],
              )
            ],
          ),
        ),
      ],
    )));
  }

  Widget logo() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover, image: AssetImage('assets/logo.png')),
      ),
    );
  }

  Widget registerButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: kThreeFoldGreenColor, padding: EdgeInsets.all(12)),
        child: Text('SIGN UP', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => goToRegister(),
      ),
    );
  }

  Widget recoverButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: kThreeFoldGreenColor, padding: EdgeInsets.all(12)),
        child: Text('RECOVER', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => goToRecover(),
      ),
    );
  }

  void goToRecover() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => RecoverScreen()));
  }

  void goToRegister() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }
}
