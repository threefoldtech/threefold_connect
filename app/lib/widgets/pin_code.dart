import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/helpers/globals.dart';

class PincodeWidget extends StatefulWidget {
  const PincodeWidget({
    super.key,
    required this.userMessage,
    required this.title,
    required this.handler,
    this.hideBackButton = false,
  });
  final String title;
  final String userMessage;
  final bool hideBackButton;
  final Function(String) handler;
  @override
  State<PincodeWidget> createState() => _PincodeWidgetState();
}

class _PincodeWidgetState extends State<PincodeWidget> {
  Globals globals = Globals();
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  Timer? _countdownTimer;
  int _remainingSeconds = -1;

  @override
  void initState() {
    super.initState();
    _checkLockRemainingTime();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLockRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lockedUntil = prefs.getInt('locked_until');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (lockedUntil != null && lockedUntil > currentTime) {
      final remainingMs = lockedUntil - currentTime;
      _startCountdown((remainingMs / 1000).ceil());
    } else {
      setState(() {
        _remainingSeconds = 0;
      });
    }
  }

  void _startCountdown(int seconds) {
    setState(() {
      _remainingSeconds = seconds;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
      }
    });
  }

  Future<void> checkAndStartCountdown() async {
    final prefs = await SharedPreferences.getInstance();
    final lockedUntil = prefs.getInt('locked_until');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (lockedUntil != null && lockedUntil > currentTime) {
      final remainingMs = lockedUntil - currentTime;
      _startCountdown((remainingMs / 1000).ceil());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final focusedBorderColor = colorScheme.primary;
    final fillColor = colorScheme.secondaryContainer;
    final borderColor = colorScheme.outline.withOpacity(0.3);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: Text(widget.title),
          automaticallyImplyLeading: widget.hideBackButton == false),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_remainingSeconds > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Try again in $_remainingSeconds seconds',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.userMessage,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 100),
              IgnorePointer(
                ignoring: _remainingSeconds != 0,
                child: Pinput(
                  autofocus: _remainingSeconds == 0,
                  obscureText: true,
                  controller: pinController,
                  focusNode: focusNode,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  onCompleted: (value) {
                    widget.handler(value);
                    pinController.clear();
                    checkAndStartCountdown();
                  },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                        color: focusedBorderColor,
                      ),
                    ],
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border:
                        Border.all(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
