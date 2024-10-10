import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/chatbot/chatbot_new.dart';
import 'package:threebotlogin/apps/chatbot/chatbot_widget.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class Chatbot implements App {
  // late ChatbotWidget _widget;
  late CrispChatbot _crispChatbot;

  @override
  Future<Widget> widget() async {
    Map<String, String?> email = await getEmail();
    String emailAddress = email['email'].toString();
    // _widget = ChatbotWidget(email: emailAddress);
    _crispChatbot = CrispChatbot(email: emailAddress);
    return _crispChatbot;
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
