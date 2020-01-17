import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/services/userService.dart';

import 'package:threebotlogin/widgets/PinField.dart';

class ChangePinScreen extends StatefulWidget {
  final currentPin;
  final bool hideBackButton;
  ChangePinScreen({this.currentPin, this.hideBackButton});
  _ChangePinScreenState createState() =>
      _ChangePinScreenState(currentPin: currentPin);
}

enum _State { CurrentPin, CurrentPinWrong, NewPinWrong, NewPin, Confirm, Done }

class _ChangePinScreenState extends State<ChangePinScreen> {
  final currentPin;
  var newPin;
  var state;
  int wrongAttempts = 0;
  int timeoutLockDelay = 5000;
  int lastWrongAttempt = 0;

  _ChangePinScreenState({this.currentPin}) {
    state = _State.NewPin;
  }

  getText() {
    // int currentTime = new DateTime.now().millisecondsSinceEpoch;

    // var timePassed = currentTime - lastWrongAttempt;

    // if (wrongAttempts >= 3 && (timePassed < timeoutLockDelay)) {
    //   return "Too many attempts, try again in ${(timeoutLockDelay - timePassed) / 1000} seconds.";
    // }

    switch (state) {
      case _State.NewPinWrong:
        return "Confirmation incorrect, Please enter your new PIN";
      case _State.NewPin:
        return "Please enter your new PIN";
      case _State.Confirm:
        return "Please confirm your new PIN";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: new AppBar(
            backgroundColor: HexColor("#2d4052"),
            title: currentPin == null
                ? Text("Choose your pincode")
                : Text("Change pincode"),
            elevation: 0.0,
            automaticallyImplyLeading: !widget.hideBackButton),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 0.0, bottom: 32.0),
              child: Center(
                  child: Text(
                getText(),
              )),
            ),
            PinField(
              callback: (p) => changePin(p),
            )
          ],
        ),
      ),
      onWillPop: () {
        if (state != _State.Done && widget.hideBackButton) {
          return Future(() => false);
        }
        return Future(() => true);
      },
    );
  }

  Future<void> changePin(enteredPinCode) async {
    setState(() {
      switch (state) {
        case _State.NewPinWrong:
        case _State.NewPin:
          newPin = enteredPinCode;
          state = _State.Confirm;
          break;
        case _State.Confirm:
          if (newPin == enteredPinCode) {
            state = _State.Done;
          } else {
            state = _State.NewPinWrong;
          }
          break;
      }
    });

    // var currentTime = new DateTime.now().millisecondsSinceEpoch;

    // var timePassed = currentTime - lastWrongAttempt;

    // if (wrongAttempts > 3) {
    //   lastWrongAttempt = new DateTime.now().millisecondsSinceEpoch;
    // }

    // if (wrongAttempts > 3 && (timePassed >= timeoutLockDelay)) {
    //   wrongAttempts = 0;
    // }

    // if (state == _State.CurrentPinWrong) {
    //   wrongAttempts++;
    //   lastWrongAttempt = new DateTime.now().millisecondsSinceEpoch;
    // }

    if (state == _State.Done) {
      await savePin(enteredPinCode);
      Navigator.pop(context, true);
    }
  }
}
