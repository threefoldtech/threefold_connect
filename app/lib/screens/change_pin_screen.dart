import 'package:flutter/material.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/pin_code.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen(
      {super.key, this.currentPin, this.hideBackButton = false});

  final String? currentPin;
  final bool hideBackButton;

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

enum _State { newPinWrong, sameOldPin, newPin, confirm, done }

class _ChangePinScreenState extends State<ChangePinScreen> {
  String newPin = '';
  _State? state;

  _ChangePinScreenState() {
    state = _State.newPin;
  }

  getText() {
    switch (state) {
      case _State.newPinWrong:
        return 'Confirmation incorrect, please enter your new PIN';
      case _State.sameOldPin:
        return "New PIN must not match the old one";
      case _State.newPin:
        return 'Please enter your new PIN';
      case _State.confirm:
        return 'Please confirm your new PIN';
      default:
        break;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.hideBackButton == false,
      child: PincodeWidget(
        title: widget.currentPin == null ? 'Choose your PIN' : 'Change PIN',
        userMessage: getText(),
        hideBackButton: widget.hideBackButton,
        handler: changePin,
      ),
    );
  }

  Future<void> changePin(String enteredPinCode) async {
    setState(() {
      switch (state) {
        case _State.newPinWrong:
        case _State.newPin:
          if (enteredPinCode == widget.currentPin) {
            state = _State.sameOldPin;
          } else {
            newPin = enteredPinCode;
            state = _State.confirm;
          }
          break;
        case _State.sameOldPin:
          if (enteredPinCode != widget.currentPin) {
            newPin = enteredPinCode;
            state = _State.confirm;
          }
          break;
        case _State.confirm:
          if (newPin == enteredPinCode) {
            state = _State.done;
          } else {
            state = _State.newPinWrong;
          }
          break;
        default:
          break;
      }
    });

    if (state == _State.done) {
      await savePin(enteredPinCode);
      Navigator.pop(context, true);
    }
  }
}
