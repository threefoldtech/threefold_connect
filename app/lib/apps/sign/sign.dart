import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/farmers/farmers_user_data.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/screens/signing/signing.dart';

class Sign implements App {
  static final Sign _singleton = Sign._internal();
  static const Widget _signWidget = Signing();

  factory Sign() {
    return _singleton;
  }

  Sign._internal();

  @override
  Future<Widget> widget() async {
    return _signWidget;
  }

  @override
  void clearData() {
    clearAllData();
  }

  @override
  bool emailVerificationRequired() {
    return false;
  }

  @override
  bool pinRequired() {
    return true;
  }

  @override
  void back() {
    Events().emit(GoHomeEvent());
  }
}
