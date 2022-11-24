import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:threebotlogin/core/crypto/services/crypto.service.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';

Future<void> saveRecoverDataToLocalStorage(String mnemonic, String username) async {
  KeyPair kp = generateKeyPairFromMnemonic(mnemonic);

  await setPrivateKey(kp.sk);
  await setPublicKey(kp.pk);

  await setPhrase(mnemonic);

  await setUsername(username);
  await setFingerPrint(false);
}
