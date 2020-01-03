import 'package:flutter/material.dart';
import 'package:threebotlogin/Apps/Chatbot/ChatbotWidget.dart';
import 'package:threebotlogin/services/userService.dart';

import '../../App.dart';

class Chatbot implements App {

  ChatbotWidget _widget;

  Future<Widget> widget() async {
    var email = await getEmail();
    this._widget = ChatbotWidget(email: email['email']);
    return this._widget;
  }

  void clearData() {
    //clearAllData();
  }

  @override
  bool emailVerificationRequired() {
    return false;
  }

}
