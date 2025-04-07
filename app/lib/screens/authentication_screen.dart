import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isLocked = false;
  bool _initializing = true;

  @override
  initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkPersistentLock();
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
      setState(() {
        isLocked = true;
      });

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

  Future<void> _checkPersistentLock() async {
    final prefs = await SharedPreferences.getInstance();
    final lockedUntil = prefs.getInt('locked_until');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    bool shouldBeLocked = lockedUntil != null && lockedUntil > currentTime;

    globals.tooManyAuthenticationAttempts = shouldBeLocked;
    globals.lockedUntill = shouldBeLocked ? lockedUntil : 0;

    setState(() {
      isLocked = shouldBeLocked;
      _initializing = false;
    });
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
    if (_initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return PincodeWidget(
      title: 'Authentication',
      userMessage: widget.userMessage,
      handler: validate,
      enabled: !isLocked,
    );
  }

  Future<void> validate(String pin) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (_initializing || isLocked || (globals.lockedUntill > currentTime)) {
      print('PIN entry blocked due to lockout.');
      return;
    }

    if (globals.tooManyAuthenticationAttempts &&
        globals.lockedUntill < currentTime) {
      globals.tooManyAuthenticationAttempts = false;
      globals.lockedUntill = 0;
      globals.incorrectPincodeAttempts = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('locked_until');
      setState(() {
        isLocked = false;
      });
    }

    if (pin == widget.correctPin && !globals.tooManyAuthenticationAttempts) {
      globals.incorrectPincodeAttempts = 0;
      globals.tooManyAuthenticationAttempts = false;
      globals.lockedUntill = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('locked_until');
      Navigator.pop(context, true);
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('locked_until', globals.lockedUntill);
        setState(() {
          isLocked = true;
        });
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
