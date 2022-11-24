import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticateWithBiometrics() async {
  bool didAuthenticate = false;
  String _localizedReason = "Please authenticate";

  try {
    didAuthenticate = await auth.authenticate(localizedReason: _localizedReason);
  } on PlatformException catch (e) {
    print(e);
    return false;
  }

  return didAuthenticate;
}

Future<String> getBiometricDeviceName() async {
  List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

  if (availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.weak)) {
    return "Face / Fingerprint";
  }

  if (availableBiometrics.contains(BiometricType.fingerprint) && availableBiometrics.contains(BiometricType.face)) {
    return "Face / Fingerprint";
  }

  if (availableBiometrics.contains(BiometricType.fingerprint) && !availableBiometrics.contains(BiometricType.face)) {
    return "Fingerprint unlock";
  }

  if (!availableBiometrics.contains(BiometricType.fingerprint) && availableBiometrics.contains(BiometricType.face)) {
    return "Face unlock";
  }

  return "Not found";
}

Future<bool> checkBiometricsAvailable() async {
  if (!(Platform.isIOS || Platform.isAndroid)) {
    return false;
  }

  return await auth.canCheckBiometrics;
}
