import 'package:flutter/material.dart';

class TermsAgreement with ChangeNotifier {
  bool _isChecked = false;
  bool _attemptedWithoutAccepting = false;

  bool get isChecked => _isChecked;
  bool get attemptedWithoutAccepting => _attemptedWithoutAccepting;

  void toggleChecked(bool value) {
    _isChecked = value;
    _attemptedWithoutAccepting = false;
    notifyListeners();
  }

  void attemptToContinue() {
    _attemptedWithoutAccepting = true;
    notifyListeners();
  }
}
