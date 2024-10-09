import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/news/news_screen.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';

class News implements App {
  static final News _singleton = News._internal();
  static const NewsScreen _newsWidget = NewsScreen();

  factory News() {
    return _singleton;
  }

  News._internal();

  @override
  Future<Widget> widget() async {
    return _newsWidget;
  }

  @override
  void clearData() {}

  @override
  bool emailVerificationRequired() {
    return false;
  }

  @override
  bool pinRequired() {
    return false;
  }

  @override
  void back() {
    Events().emit(GoHomeEvent());
  }
}
