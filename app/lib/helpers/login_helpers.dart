import 'dart:convert';
import 'dart:typed_data';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

int parseImageId(String imageId) {
  if (imageId == '') {
    return 1;
  }
  return int.parse(imageId);
}

// Only update data if the correct image was chosen:
void addDigitalTwinToBackend(Uint8List derivedSeed, String appId) async {
  String? doubleName = await getDoubleName();

  KeyPair dtKeyPair = await generateKeyPairFromEntropy(derivedSeed);
  String dtEncodedPublicKey = base64.encode(dtKeyPair.publicKey);

  addDigitalTwinDerivedPublicKeyToBackend(
      doubleName, dtEncodedPublicKey, appId);
}

Future<Map<String, dynamic>?> readScopeAsObject(
    String? scopePermissions, Uint8List dSeed) async {
  Map<String, dynamic>? scopePermissionsDecoded = jsonDecode(scopePermissions!);

  Map<String, dynamic> scope = {};

  if (scopePermissionsDecoded == null) {
    return null;
  }

  if (scopePermissionsDecoded['email'] == true) {
    scope['email'] = (await getEmail());
  }

  if (scopePermissionsDecoded['phone'] == true) {
    scope['phone'] = (await getPhone());
  }

  if (scopePermissionsDecoded['derivedSeed'] == true) {
    scope['derivedSeed'] = base64Encode(dSeed);
  }

  if (scopePermissionsDecoded['digitalTwin'] == true) {
    scope['digitalTwin'] = 'OK';
  }


  if (scopePermissionsDecoded['walletAddress'] == true) {
    scope['walletAddressData'] = {
      'address': scopePermissionsDecoded['walletAddressData']
    };
  }

  return scope;
}

Future<Map<String, String>> encryptLoginData(
    String publicKey, Map<String, dynamic>? scopeData) async {
  Uint8List sk = await getPrivateKey();
  Uint8List pk = base64.decode(publicKey);

  return await encrypt(jsonEncode(scopeData), pk, sk);
}
