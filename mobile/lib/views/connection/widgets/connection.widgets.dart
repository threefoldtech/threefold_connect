import 'package:flutter/material.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';

Widget retryButton(String? errorMessage, Function cb) {
  return Visibility(
      maintainAnimation: true,
      maintainState: true,
      maintainSize: true,
      visible: errorMessage != null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: kThreeFoldGreenColor, padding: EdgeInsets.all(12)),
        child: Text('RETRY', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => cb(),
      ));
}

Widget message(String? updateMessage, String? errorMessage) {
  return Container(
    padding: EdgeInsets.only(left: 12, right: 12),
    child: Text(
      updateMessage != null ? updateMessage.trim() : errorMessage!.trim(),
      style:
          TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: errorMessage != null ? kErrorColor : kTextColor),
    ),
  );
}

Widget logo = Image.asset(
  'assets/logo.png',
  height: 100,
);
