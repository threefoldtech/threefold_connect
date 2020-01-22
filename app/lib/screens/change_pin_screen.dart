import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/pin_field.dart';

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

  _ChangePinScreenState({this.currentPin}) {
    state = _State.NewPin;
  }

  getText() {
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

    if (state == _State.Done) {
      await savePin(enteredPinCode);
      Navigator.pop(context, true);
    }
  }
}
