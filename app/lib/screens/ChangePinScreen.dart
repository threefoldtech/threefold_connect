import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/services/userService.dart';

import 'package:threebotlogin/widgets/PinField.dart';

class ChangePinScreen extends StatefulWidget {
  final currentPin;
  bool hideBackButton;
  ChangePinScreen({this.currentPin, this.hideBackButton});
  _ChangePinScreenState createState() =>
      _ChangePinScreenState(currentPin: currentPin);
}

enum _State { CurrentPin, CurrentPinWrong, NewPinWrong, NewPin, Confirm, Done }

class _ChangePinScreenState extends State<ChangePinScreen> {
  final currentPin;
  var newPin;
  var state;

  _ChangePinScreenState({this.currentPin}) {
    state = currentPin == null ? _State.NewPin : _State.CurrentPin;
  }
  getText() {
    switch (state) {
      case _State.CurrentPin:
        return "Please enter your current PIN";
      case _State.CurrentPinWrong:
        return "The PIN you entered was not correct, enter your current PIN";
      case _State.NewPinWrong:
        return "The PIN did not match. Enter your new PIN";
      case _State.NewPin:
        return "Please enter your new PIN";
      case _State.Confirm:
        return "Please confirm your new PIN";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: HexColor("#2d4052"),
        title: currentPin == null ? Text("Choose your pincode") : Text("Change pincode"),
        elevation: 0.0,
        automaticallyImplyLeading: !widget.hideBackButton
      ),
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
    );
  }

  Future<void> changePin(enteredPinCode) async {
    setState(() {
      switch (state) {
        case _State.CurrentPinWrong:
        case _State.CurrentPin:
          if (enteredPinCode == currentPin) {
            state = _State.NewPin;
          } else {
            state = _State.CurrentPinWrong;
          }
          break;
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
    if (state == _State.Done) {
      await savePin(enteredPinCode);
      Navigator.pop(context);
    }
  }
}
