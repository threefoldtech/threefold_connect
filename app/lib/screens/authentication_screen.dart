import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/events/close_auth_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/services/fingerprint_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen(
      {super.key, this.correctPin, required this.userMessage, this.loginData});

  final int pinLength = 4;
  final String? correctPin;
  final String userMessage;
  final Login? loginData;

  @override
  State<AuthenticationScreen> createState() => AuthenticationScreenState();
}

class AuthenticationScreenState extends State<AuthenticationScreen> {
  int timeout = 30000;
  Globals globals = Globals();
  late Timer timer;

  @override
  initState() {
    super.initState();

    Events().onEvent(CloseAuthEvent().runtimeType, (CloseAuthEvent event) {
      if (mounted) {
        close();
      }
    });

    if (widget.loginData != null && widget.loginData!.isMobile == false) {
      const oneSec = Duration(seconds: 1);

      timer = Timer.periodic(oneSec, (Timer t) async {
        timeoutTimer();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => checkFingerprint());
  }

  timeoutTimer() async {
    if (!mounted) {
      timer.cancel();
      return;
    }

    int? created = widget.loginData!.created;
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    if (created != null &&
        ((currentTimestamp - created) / 1000) > Globals().loginTimeout) {
      timer.cancel();

      await showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          image: Icons.timer,
          title: 'Login attempt expired',
          description:
              'Your login attempt has expired, please request a new one in your browser.',
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      );

      Navigator.pop(context, false);
    }
  }

  close() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
    }
  }

  checkFingerprint() async {
    bool? isFingerprintEnabled = await getFingerprint();

    if (isFingerprintEnabled == true) {
      bool isAuthenticated = await authenticate();

      if (isAuthenticated) {
        Navigator.pop(context, true);
      }
    }
  }

  List<String> input = [];

  Widget buildTextField(int i, BuildContext context) {
    const double maxSize = 7;
    double size = input.length > i ? maxSize : 1;
    double height = MediaQuery.of(context).size.height;
    return AnimatedContainer(
      margin: EdgeInsets.all(height / 120),
      height: height / 50,
      width: size,
      decoration:
          const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      duration: const Duration(milliseconds: 100),
      curve: Curves.bounceInOut,
    );
  }

  Widget buildNumberPin(String buttonText, BuildContext context,
      {Color backgroundColor = Colors.blueGrey}) {
    var onPressedMethod = () => handleInput(buttonText);
    double height = MediaQuery.of(context).size.height;

    if (buttonText == 'OK') {
      onPressedMethod =
          (input.length >= widget.pinLength ? () => onOk() : () {});
    }
    if (buttonText == 'C') {
      onPressedMethod = (input.isNotEmpty ? () => onClear() : () {});
    }
    return Container(
        padding: EdgeInsets.only(top: height / 136, bottom: height / 136),
        child: Center(
            child: RawMaterialButton(
          padding: const EdgeInsets.all(12),
          onPressed: onPressedMethod,
          fillColor: backgroundColor,
          shape: const CircleBorder(),
          child: Text(
            buttonText,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        )));
  }

  Widget generateNumbers(BuildContext context) {
    List<String> possibleInput = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'C',
      '0',
      'OK'
    ];
    List<Widget> pins = List.generate(possibleInput.length, (int i) {
      String buttonText = possibleInput[i];
      if (buttonText == 'C') {
        return buildNumberPin(possibleInput[i], context,
            backgroundColor: input.isNotEmpty
                ? Colors.yellow.shade700
                : Colors.yellow.shade200);
      } else if (buttonText == 'OK') {
        return buildNumberPin(possibleInput[i], context,
            backgroundColor: input.length >= widget.pinLength
                ? Colors.green.shade600
                : Colors.green.shade100);
      } else {
        return buildNumberPin(possibleInput[i], context,
            backgroundColor: HexColor('#0a73b8'));
      }
    });
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: pins.take(3).toList()),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: pins.skip(3).take(3).toList()),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: pins.skip(6).take(3).toList()),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: pins.skip(9).take(3).toList()),
          ],
        ),
      ),
    );
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.pinLength, (int i) {
      return buildTextField(i, context);
    });

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: textFields);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: HexColor('#0a73b8'),
        title: const Text('Authentication'),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: Text(widget.userMessage),
            ),
            Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Column(
                children: [
                  generateTextFields(context),
                  const SizedBox(height: 25),
                  generateNumbers(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onOk() async {
    HapticFeedback.mediumImpact();

    String pin = '';
    for (var char in input) {
      pin += char;
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (globals.incorrectPincodeAttempts >= 3 &&
        (globals.tooManyAuthenticationAttempts &&
            globals.lockedUntill < currentTime)) {
      globals.tooManyAuthenticationAttempts = false;
      globals.lockedUntill = 0;
      globals.incorrectPincodeAttempts = 0;
    }

    if (pin == widget.correctPin && !globals.tooManyAuthenticationAttempts) {
      globals.incorrectPincodeAttempts = 0;
      Navigator.pop(context, pin == widget.correctPin);
      return;
    }

    if (pin != widget.correctPin) {
      globals.incorrectPincodeAttempts++;
    }

    CustomDialog dialog;

    if (globals.incorrectPincodeAttempts >= 3 ||
        (globals.tooManyAuthenticationAttempts &&
            globals.lockedUntill >= currentTime)) {
      if (!globals.tooManyAuthenticationAttempts) {
        globals.tooManyAuthenticationAttempts = true;
        globals.lockedUntill = currentTime + timeout;
      }

      dialog = CustomDialog(
        title: 'Too many attempts',
        description:
            'Too many incorrect attempts, please wait ${((globals.lockedUntill - currentTime) / 1000).toStringAsFixed(0)} seconds',
      );
    } else {
      dialog = const CustomDialog(
        title: 'Incorrect pin',
        description: 'Your pin code is incorrect.',
      );
    }

    await dialog.show(context);

    setState(() {
      input.removeRange(0, 4);
    });
  }

  void onClear() {
    HapticFeedback.mediumImpact();
    setState(() {
      input.removeLast();
    });
  }

  void handleInput(String buttonText) async {
    if (input.length < widget.pinLength) {
      HapticFeedback.lightImpact();
      setState(() {
        input.add(buttonText);
      });
    }
  }
}
