import 'package:flutter/material.dart';

class OrderNotifier {
  static final ValueNotifier<bool> orderUpdated = ValueNotifier(false);

  static void emitUpdate() {
    orderUpdated.value = !orderUpdated.value;
  }
}
