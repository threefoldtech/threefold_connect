import 'package:flutter/material.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpWidget.dart';



import '../../App.dart';

class Ffp implements App{
  @override
  Future<Widget> widget() async{
    return  FfpWidget();
  }

  void clearData(){
    //clearAllData();
  }
}