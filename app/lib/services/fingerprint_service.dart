import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticate() async {
  bool didAuthenticate = false;
  String _localizedReason = "";

  try {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
        _localizedReason = "Please authenticate with Face ID.";
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        _localizedReason = "Please authenticate with Touch ID.";
      }
    } else if (Platform.isAndroid) {
      if (availableBiometrics.contains(BiometricType.face)) {
        _localizedReason = "Please authenticate with face unlock.";
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        _localizedReason = "Please authenticate with your fingerprint.";
      }
    }

    didAuthenticate = await auth.authenticateWithBiometrics(
        localizedReason: _localizedReason,
        useErrorDialogs: true);
  } on PlatformException catch (e) {
    print(e);
    return false;
  }

  return didAuthenticate;
}

Future<String> getBiometricDeviceName() async {
  List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
        
  if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
        return "Face ID";
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return "Touch ID";
      }
    } else if (Platform.isAndroid) {
      if (availableBiometrics.contains(BiometricType.face)) {
        return "Face unlock";
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return "Fingerprint";
      }
    }

    return "Not found";
}

Future<bool> checkBiometricsAvailable() async {
  if (!(Platform.isIOS || Platform.isAndroid)) {
    return false;
  }

  return await auth.canCheckBiometrics;
}
