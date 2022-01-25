import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/farmers/farmers_events.dart';
import 'package:threebotlogin/apps/farmers/farmers_user_data.dart';
import 'package:threebotlogin/apps/farmers/farmers_widget.dart';
import 'package:threebotlogin/events/events.dart';

class Farmers implements App {
  static final Farmers _singleton = new Farmers._internal();
  static final FarmersWidget _farmersWidget = FarmersWidget();

  factory Farmers() {
    return _singleton;
  }

  Farmers._internal();

  Future<Widget> widget() async {
    return _farmersWidget;
  }

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
    Events().emit(FarmersBackEvent());
  }
}
