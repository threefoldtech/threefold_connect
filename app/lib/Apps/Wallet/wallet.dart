import 'package:flutter/material.dart';
import 'package:threebotlogin/Apps/Wallet/walletEvents.dart';
import 'package:threebotlogin/Apps/Wallet/walletUserData.dart';
import 'package:threebotlogin/Apps/Wallet/walletWidget.dart';
import 'package:threebotlogin/Events/Events.dart';

import '../../App.dart';

class Wallet implements App {
  static final Wallet _singleton = new Wallet._internal();
  static final WalletWidget _walletWidget = WalletWidget();
  factory Wallet() {
    return _singleton;
  }

  Wallet._internal() {}

  Future<Widget> widget() async {
    return _walletWidget;
  }

  void clearData() {
    clearAllData();
  }

  @override
  bool emailVerificationRequired() {
    return false;
  }

  @override
  void back() {
    Events().emit(WalletBackEvent());
  }
}
