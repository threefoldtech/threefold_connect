import 'package:flutter/material.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpEvents.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpWidget.dart';
import 'package:threebotlogin/Events/Events.dart';

import '../../App.dart';

class Ffp implements App {
  static final Ffp _singleton = new Ffp._internal();
  static final FfpWidget _ffpWidget = FfpWidget();
  factory Ffp() {
    return _singleton;
  }

  Ffp._internal() {}

  @override
  Future<Widget> widget() async {
    return _ffpWidget;
  }
  void back(){
    Events().emit(FfpBackEvent());
    
  }
  void clearData() {
    //clearAllData();
  }

  @override
  bool emailVerificationRequired() {
    return true;
  }
}
