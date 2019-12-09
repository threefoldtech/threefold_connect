import 'package:flutter/material.dart';
import 'package:threebotlogin/services/userService.dart';

import 'package:threebotlogin/widgets/PinField.dart';

class ChangePinScreen extends StatefulWidget {
  ChangePinScreen({Key key}) : super(key: key);
  _ChangePinScreenState createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  bool pinChanged = false;
  bool oldPinOk = false;
  String helperText = 'Enter old pincode';
  var newPin;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text("Change pincode"),
        elevation: 0.0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Container(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Container(
              padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 0.0, bottom: 32.0),
                      child: Center(
                          child: Text(
                        helperText,
                      )),
                    ),
                    !pinChanged
                        ? PinField(
                            callback: (p) => changePin(p),
                          )
                        : succesfulChange(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  changePin(p) async {
    final oldPin = await getPin();

    if (!oldPinOk) {
      checkUserCurrentPin(oldPin, p);
    } else {
      if (newPin == null) {
        newPin = p;
        checkUserNewPin(oldPin);
      } else {
        confirmUserNewPin(p);
      }
    }
  }

  void confirmUserNewPin(p) {
    if (newPin == p) {
      savePin(newPin);
      setState(() {
        helperText = '';
        pinChanged = true;
      });
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Oops... pin does not match'),
          duration: Duration(milliseconds: 500)));
    }
  }

  void checkUserNewPin(String oldPin) {
     if (newPin == oldPin) {
       setState(() {
        newPin = null;
      });

      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Oops... pin is the same as current pin'),
          duration: Duration(milliseconds: 500)));
    } else {
      setState(() {
        helperText = "Confirm new pincode";
      });
    }
  }

  void checkUserCurrentPin(String oldPin, p) {
    if (oldPin == p) {
      setState(() {
        helperText = "Enter new pincode";
        oldPinOk = true;
      });
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Oops... you entered the wrong pin'),
          duration: Duration(milliseconds: 500)));
    }
  }

  Widget succesfulChange() {
    return Container(
      padding: EdgeInsets.only(top: 24.0, bottom: 38.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check_circle,
              size: 42.0,
              color: Theme.of(context).accentColor,
            ),
            SizedBox(
              height: 20.0,
            ),
            Text('You have successfully changed you pincode'),
            SizedBox(
              height: 60.0,
            ),
          ],
        ),
      ),
    );
  }
}
