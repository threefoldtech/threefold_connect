import 'package:flutter/widgets.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/farmers/farmers_user_data.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/screens/market_screen.dart';

class Market implements App {
  static final Market _singleton = Market._internal();
  static const Widget _daoWidget = MarketPage();

  factory Market() {
    return _singleton;
  }

  Market._internal();

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
