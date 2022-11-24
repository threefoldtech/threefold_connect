import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

Future<void> setToClipboard(String text) async {
  Clipboard.setData(new ClipboardData(text: text));
  final snackBar = SnackBar(content: Text('Address copied to clipboard'));

  ScaffoldMessenger.of(Globals().globalBuildContext).showSnackBar(snackBar);
}

String randomString(int len) {
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  String result = "";

  for (int i = 0; i < len; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }

  return result;
}