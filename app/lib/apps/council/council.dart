import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/farmers/farmers_user_data.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/screens/council_screen.dart';

class Council implements App {
  static final Council _singleton = Council._internal();
  static const Widget _councilWidget = CouncilScreen();

  factory Council() {
    return _singleton;
  }

  Council._internal();

  @override
  Future<Widget> widget() async {
    return _councilWidget;
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
