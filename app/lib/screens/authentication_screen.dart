import 'dart:async';

import 'package:flutter/material.dart';
import 'package:threebotlogin/events/close_auth_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/login.dart';
import 'package:threebotlogin/services/fingerprint_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/pin_code.dart';

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

  @override
  Widget build(BuildContext context) {
    return PincodeWidget(
      title: 'Authentication',
      userMessage: widget.userMessage,
      handler: validate,
    );
  }

  validate(String pin) {
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

    dialog.show(context);
  }
}
