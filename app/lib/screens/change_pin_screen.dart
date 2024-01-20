import 'package:flutter/material.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/pin_field.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key, this.currentPin, this.hideBackButton});

  final String? currentPin;
  final bool? hideBackButton;

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

enum _State { newPinWrong, newPin, confirm, done }

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
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
            title: widget.currentPin == null
                ? const Text('Choose your pincode')
                : const Text('Change pincode'),
            elevation: 0.0,
            automaticallyImplyLeading: widget.hideBackButton == false),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 0.0, bottom: 32.0),
              child: Center(
                  child: Text(
                getText(),
                style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onBackground),
              )),
            ),
            PinField(
              callback: (p) => changePin(p),
            )
          ],
        ),
      ),
      onWillPop: () {
        if (state != _State.done && widget.hideBackButton == true) {
          return Future(() => false);
        }
        return Future(() => true);
      },
    );
  }

  Future<void> changePin(String enteredPinCode) async {
    setState(() {
      switch (state) {
        case _State.newPinWrong:
        case _State.newPin:
          newPin = enteredPinCode;
          state = _State.confirm;
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
