/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

/// This is the screen that you'll see when the app starts
class GenerateQRCodeScreen extends StatefulWidget {
  const GenerateQRCodeScreen({
    super.key,
    required this.message,
  });

  final String message;

  @override
  State<GenerateQRCodeScreen> createState() => _GenerateQRCodeScreenState();
}

class _GenerateQRCodeScreenState extends State<GenerateQRCodeScreen> {
  @override
  void initState() {
    ScreenBrightness().setScreenBrightness(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Scan QR code',
      image: Icons.qr_code,
      widgetDescription: Center(
        child: Container(
          color: Colors.white,
          width: 280,
          child: QrImageView(
            data: widget.message,
            version: QrVersions.auto,
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            ScreenBrightness().resetScreenBrightness();
            Navigator.pop(context);
            setState(() {});
          },
        ),
      ],
    );
  }
}
