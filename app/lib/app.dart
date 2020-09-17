import 'package:flutter/material.dart';

abstract class App {
  Future<Widget> widget();

  void clearData();

  bool emailVerificationRequired();

  bool pinRequired();

  void back();
}
