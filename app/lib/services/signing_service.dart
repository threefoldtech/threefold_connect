import 'package:crypto/crypto.dart';
import 'package:threebotlogin/services/tfchain_service.dart';

Future<String> md5Sign(
    {required String data, required String walletSecretSeed}) async {
  final contentHash = md5.convert(data.codeUnits).toString();
  final signer = await getSignerFromSeed(walletSecretSeed);
  return signer.sign(contentHash);
}
