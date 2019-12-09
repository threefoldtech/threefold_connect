import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticate() async {
  bool authenticated = false;
  try {
    authenticated = await auth.authenticateWithBiometrics(
        localizedReason: 'Scan your fingerprint to authenticate',
        useErrorDialogs: true);
  } on PlatformException catch (e) {
    print(e);
  }

  return authenticated;
}

Future<bool> checkBiometricsAvailable() async {
  return await auth.canCheckBiometrics;
}