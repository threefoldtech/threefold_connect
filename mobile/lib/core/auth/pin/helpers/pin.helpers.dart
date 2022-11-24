import 'package:flutter/material.dart';
import 'package:threebotlogin/core/auth/pin/views/auth.view.dart';
import 'package:threebotlogin/core/storage/auth/auth.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

Future<bool?> authenticateYourself() async {
  String? pin = await getPin();
  bool? authenticated = await Navigator.push(
      Globals().globalBuildContext,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
          correctPin: pin!,
          userMessage: "Please enter your PIN code",
        ),
      ));

  return authenticated;
}
