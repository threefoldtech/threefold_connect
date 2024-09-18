import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

bool isValidStellarSecret(String seed) {
  try {
    StrKey.decodeStellarSecretSeed(seed);
    return true;
  } catch (e) {
    print('Secret is invalid. $e');
  }
  return false;
}
