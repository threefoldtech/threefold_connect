import 'package:flutter/material.dart';
import 'package:threebotlogin/Apps/Chatbot/ChatbotWidget.dart';

import '../../App.dart';

class Chatbot implements App{
  Widget widget(){
    return  ChatbotWidget();
  }

  void clearData(){
    //clearAllData();
  }
}