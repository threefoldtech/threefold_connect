import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/chatbot/chatbot_widget.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/services/user_service.dart';

class Chatbot implements App {
  ChatbotWidget _widget;

  Future<Widget> widget() async {
    var email = await getEmail();
    this._widget = ChatbotWidget(email: email['email']);
    return this._widget;
  }

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
