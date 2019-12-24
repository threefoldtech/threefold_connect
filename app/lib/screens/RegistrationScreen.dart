
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

import 'package:threebotlogin/widgets/Scanner.dart';

class RegistrationScreen extends StatefulWidget {
  final Widget registrationScreen;

  RegistrationScreen({Key key, this.registrationScreen}) : super(key: key);
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  String helperText = "Aim at QR code to scan";
  AnimationController sliderAnimationController;
  Animation<double> offset;
  
  String pin;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var scope = Map();
  var keys;

  @override
  void initState() {
    super.initState();
    sliderAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    sliderAnimationController.addListener(() {
      this.setState(() {});
    });

    offset = Tween<double>(begin: 0.0, end: 500.0).animate(CurvedAnimation(
        parent: sliderAnimationController, curve: Curves.bounceOut));
  }

  Widget content() {
    double height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 60.0,
                ),
                Text(
                  'Scan QR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21.0),
                ),
                FloatingActionButton(
                  tooltip: "What should I do?",
                  mini: true,
                  onPressed: () {
                    _showInformation();
                  },
                  child: Icon(Icons.help_outline),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Theme.of(context).primaryColor,
          child: Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0))),
              padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: height / 100, bottom: 12),
                    child: Center(
                      child: Text(
                        helperText,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    padding: EdgeInsets.only(bottom: 12),
                    curve: Curves.bounceInOut,
                    width: double.infinity,
                    child: null,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Scanner(
            callback: (qr) => gotQrData(qr),
            context: context,
          ),
          Align(alignment: Alignment.bottomCenter, child: content()),
        ],
      ),
    );
  }

  gotQrData(value) async {

    Navigator.pop(context, value);
  }

  showError() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Something went wrong, please try again later.'),
    ));
  }

  pinFilledIn(String value) async {
  //deprecated
  }

  saveValues() async {
   //deprecated
  }

  _showInformation() {
    var _stepsList =
        'Step 1: Go to the website: https://www.freeflowpages.com/  \n' +
            'Step 2: Create an account\n' +
            'Step 3: Scan the QR code\n';

    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: "Steps",
        description: new Text(
          _stepsList,
          textAlign: TextAlign.center,
          textScaleFactor: 1.2,
        ),
        actions: <Widget>[
          FlatButton(
            child: new Text("Continue"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
