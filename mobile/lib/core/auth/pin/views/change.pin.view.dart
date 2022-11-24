import 'package:flutter/material.dart';
import 'package:threebotlogin/core/auth/pin/widgets/pin.widgets.dart';
import 'package:threebotlogin/core/storage/auth/auth.storage.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';

class ChangePinScreen extends StatefulWidget {
  final currentPin;
  final bool? hideBackButton;

  ChangePinScreen({this.currentPin, this.hideBackButton});

  _ChangePinScreenState createState() => _ChangePinScreenState();
}

enum _State { NewPinWrong, NewPin, Confirm, Done }

class _ChangePinScreenState extends State<ChangePinScreen> {
  String newPin = '';
  _State? state;

  _ChangePinScreenState() {
    state = _State.NewPin;
  }

  getText() {
    switch (state) {
      case _State.NewPinWrong:
        return "Confirmation incorrect, please enter your new PIN";
      case _State.NewPin:
        return "Please enter your new PIN";
      case _State.Confirm:
        return "Please confirm your new PIN";
      default:
        break;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: new AppBar(
            backgroundColor: kAppBarColor,
            title: widget.currentPin == null ? Text("Choose your PIN") : Text("Change PIN"),
            elevation: 0.0,
            automaticallyImplyLeading: widget.hideBackButton == false),
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
        if (state != _State.Done && widget.hideBackButton == true) {
          return Future(() => false);
        }
        return Future(() => true);
      },
    );
  }

  Future<void> changePin(String enteredPinCode) async {
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
        default:
          break;
      }
    });

    if (state == _State.Done) {
      await savePin(enteredPinCode);
      Navigator.pop(context, true);
    }
  }
}
