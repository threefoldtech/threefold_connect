import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/farmers/farmers_user_data.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/screens/dao_screen.dart';

class Dao implements App {
  static final Dao _singleton = Dao._internal();
  static const Widget _daoWidget = DaoPage();

  factory Dao() {
    return _singleton;
  }

  Dao._internal();

  @override
  Future<Widget> widget() async {
    return _daoWidget;
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
