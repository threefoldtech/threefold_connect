import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/farmers/farmers_user_data.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/screens/notifications_screen.dart';

class Notifications implements App {
  static final Notifications _singleton = Notifications._internal();
  static const Widget _notificationsWidget = NotificationsScreen();

  factory Notifications() {
    return _singleton;
  }

  Notifications._internal();

  @override
  Future<Widget> widget() async {
    return _notificationsWidget;
  }

  @override
  void clearData() {
    clearAllData();
  }

  @override
  bool emailVerificationRequired() {
    return true;
  }

  @override
  bool pinRequired() {
    return true;
  }

  @override
  void back() {
    Events().emit(GoHomeEvent());
  }
} // TODO Implement this library.
