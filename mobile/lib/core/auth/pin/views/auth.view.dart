import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/core/auth/biometrics/services/biometric.service.dart';
import 'package:threebotlogin/core/auth/pin/dialogs/auth.dialogs.dart';
import 'package:threebotlogin/core/auth/pin/widgets/auth.widgets.dart';
import 'package:threebotlogin/core/events/classes/event.classes.dart';
import 'package:threebotlogin/core/events/services/events.service.dart';
import 'package:threebotlogin/core/storage/auth/auth.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';

class AuthenticationScreen extends StatefulWidget {
  final int pinLength = 4;
  final String correctPin;
  final String? userMessage;

  @override
  AuthenticationScreen({required this.correctPin, this.userMessage});

  @override
  AuthenticationScreenState createState() => AuthenticationScreenState();
}

class AuthenticationScreenState extends State<AuthenticationScreen> {
  late Timer timer;

  void initState() {
    super.initState();

    Events().onEvent(CloseAuthEvent().runtimeType, (CloseAuthEvent event) {
      if (mounted) close();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => checkFingerprint());
  }

  checkFingerprint() async {
    bool? isFingerprintEnabled = await getFingerPrint();

    if (isFingerprintEnabled == true && Globals().canUseBiometrics) {
      bool isAuthenticated = await authenticateWithBiometrics();

      if (isAuthenticated) {
        Navigator.pop(context, true);
      }
    }
  }

  close() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
    }
  }

  List<String> input = [];

  Widget buildTextField(int i) {
    const double maxSize = 7;
    double size = input.length > i ? maxSize : 1;
    double height = MediaQuery.of(context).size.height;
    return AnimatedContainer(
      margin: EdgeInsets.all(height / 120),
      height: height / 50,
      width: size,
      decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      duration: Duration(milliseconds: 100),
      curve: Curves.bounceInOut,
    );
  }

  Widget buildNumberPin(String buttonText, {Color backgroundColor: Colors.blueGrey}) {
    var onPressedMethod = () => handleInput(buttonText);
    double height = MediaQuery.of(context).size.height;

    if (buttonText == 'OK') onPressedMethod = (input.length >= widget.pinLength ? () => onOk() : () {});
    if (buttonText == 'C') onPressedMethod = (input.length >= 1 ? () => onClear() : () {});
    return Container(
        padding: EdgeInsets.only(top: height / 136, bottom: height / 136),
        child: Center(
            child: RawMaterialButton(
          padding: EdgeInsets.all(12),
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: onPressedMethod,
          fillColor: backgroundColor,
          shape: CircleBorder(),
        )));
  }

  Widget generateNumbers() {
    List<String> possibleInput = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', 'OK'];
    List<Widget> pins = List.generate(possibleInput.length, (int i) {
      String buttonText = possibleInput[i];
      if (buttonText == 'C')
        return buildNumberPin(possibleInput[i],
            backgroundColor: input.length >= 1 ? Colors.yellow.shade700 : Colors.yellow.shade200);
      else if (buttonText == 'OK')
        return buildNumberPin(possibleInput[i],
            backgroundColor: input.length >= widget.pinLength ? Colors.green.shade600 : Colors.green.shade100);
      else
        return buildNumberPin(possibleInput[i], backgroundColor: kAppBarColor);
    });

    return authPins(pins);
  }

  Widget generateTextFields() {
    List<Widget> textFields = List.generate(widget.pinLength, (int i) {
      return buildTextField(i);
    });

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: textFields);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: new AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: kAppBarColor,
            title: Text("Authentication"),
          ),
          body: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(widget.userMessage != null ? widget.userMessage! : "Please enter your PIN"),
                  padding: const EdgeInsets.only(bottom: 50),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Column(
                    children: [
                      generateTextFields(),
                      SizedBox(height: 25),
                      generateNumbers(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context, false);
          }

          return Future.value(false);
        });
  }

  Future<void> onOk() async {
    HapticFeedback.heavyImpact();

    String pin = "";
    input.forEach((char) => pin += char);

    int lockedUntil = await getLockedUntil();
    int failedAuthAttempts = await getFailedAuthAttempts();

    int currentTime = new DateTime.now().millisecondsSinceEpoch;

    // Unblock if necessary
    if (lockedUntil < currentTime && failedAuthAttempts >= 3) {
      await setLockedUntil(0);
      await setFailedAuthAttempts(0);
    }

    lockedUntil = await getLockedUntil();
    failedAuthAttempts = await getFailedAuthAttempts();

    // Locked status
    if (lockedUntil > currentTime || failedAuthAttempts > 3) {
      setState(() => input.removeRange(0, 4));
      return await showTooManyAttempts();
    }

    // Incorrect pin but not locked yet
    if (pin != widget.correctPin) {
      await setFailedAuthAttempts(null);
      failedAuthAttempts = await getFailedAuthAttempts();

      // Set blocked time
      if (failedAuthAttempts >= 3) {
        await setLockedUntil(currentTime + 60000);
        setState(() => input.removeRange(0, 4));
        return await showTooManyAttempts();
      }

      setState(() => input.removeRange(0, 4));
      return await showIncorrectPin();
    }

    // Pin correct + not blocked and redirect
    if (pin == widget.correctPin) {
      await setLockedUntil(0);
      await setFailedAuthAttempts(0);

      Navigator.pop(context, true);
      setState(() => input.removeRange(0, 4));
      return;
    }
  }

  void onClear() {
    HapticFeedback.heavyImpact();
    setState(() {
      input.removeLast();
    });
  }

  void handleInput(String buttonText) async {
    if (input.length < widget.pinLength) {
      HapticFeedback.heavyImpact();
      setState(() {
        input.add(buttonText);
      });
    }
  }
}
