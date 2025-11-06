import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:threebotlogin/helpers/logger.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticate() async {
  bool didAuthenticate = false;
  String localizedReason = '';

  try {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
        localizedReason = 'Please authenticate with Face ID.';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        localizedReason = 'Please authenticate with Touch ID.';
      }
    } else if (Platform.isAndroid) {
      // Android supports strong/weak biometrics
      if (availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.weak) ||
          availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.fingerprint)) {
        localizedReason = 'Please authenticate to continue.';
      }
    }

    didAuthenticate = await auth.authenticate(
      localizedReason: localizedReason,
      options: const AuthenticationOptions(
        biometricOnly: true,
        useErrorDialogs: true,
      ),
    );
  } on PlatformException catch (e) {
    logger.e(e);
    return false;
  }

  return didAuthenticate;
}

Future<String> getBiometricDeviceName() async {
  try {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Touch ID';
      }
    } else if (Platform.isAndroid) {
      // Check for strong/weak biometrics (Android 11+)
      if (availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.weak)) {
        return 'Biometric unlock';
      }
      // Fallback to specific types
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face unlock';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      }
    }
  } catch (e) {
    logger.e('Error getting biometric device name: $e');
  }

  return 'Not found';
}

Future<bool> checkBiometricsAvailable() async {
  if (!(Platform.isIOS || Platform.isAndroid)) {
    return false;
  }

  try {
    // Check if device supports biometrics
    final bool isDeviceSupported = await auth.isDeviceSupported();
    if (!isDeviceSupported) {
      return false;
    }

    // Check if biometrics are available (enrolled)
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      return false;
    }

    // Check if there are any biometrics enrolled
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  } catch (e) {
    logger.e('Error checking biometrics availability: $e');
    return false;
  }
}
