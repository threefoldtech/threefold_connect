import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/jrouter.dart';

class Globals {
  static final bool isInDebugMode = true;
  static final HexColor color = HexColor("#0a73b8");

  ValueNotifier<bool> emailVerified = ValueNotifier(false);

  final JRouter router = new JRouter();

  int incorrectPincodeAttempts = 0;
  bool tooManyAuthenticationAttempts = false;

  int lockedUntill = 0;
  int loginTimeout = 120;

  static final Globals _singleton = new Globals._internal();

  factory Globals() {
    return _singleton;
  }

  Globals._internal();
}
