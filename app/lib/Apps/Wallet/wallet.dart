import 'package:flutter/material.dart';
import 'package:threebotlogin/Apps/Wallet/walletUserData.dart';
import 'package:threebotlogin/Apps/Wallet/walletWidget.dart';


import '../../App.dart';

class Wallet implements App{
  Widget widget(){
    return  WalletWidget();
  }

  void clearData(){
    clearAllData();
  }
}