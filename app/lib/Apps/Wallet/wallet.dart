import 'package:flutter/material.dart';
import 'package:threebotlogin/Apps/Wallet/walletUserData.dart';
import 'package:threebotlogin/Apps/Wallet/walletWidget.dart';


import '../../App.dart';

class Wallet implements App {
  Future<Widget> widget() async{
    return  WalletWidget();
  }
 
  void clearData(){
    clearAllData();
  }

  @override
  bool emailVerificationRequired() {
    return false;
  }
}