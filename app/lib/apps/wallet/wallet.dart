import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/wallet/wallet_events.dart';
import 'package:threebotlogin/apps/wallet/wallet_user_data.dart';
import 'package:threebotlogin/apps/wallet/wallet_widget.dart';
import 'package:threebotlogin/events/events.dart';

class Wallet implements App {
  static final Wallet _singleton = new Wallet._internal();
  static final WalletWidget _walletWidget = WalletWidget();

  factory Wallet() {
    return _singleton;
  }

  Wallet._internal();

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
  bool pinRequired() {
    return true;
  }

  @override
  void back() {
    Events().emit(WalletBackEvent());
  }
}
