import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:stellar_client/stellar_client.dart' as Stellar;
import 'package:convert/convert.dart';
import 'package:tfchain_client/tfchain_client.dart' as TFChain;

Future<int?> getTwinId() async {
  final chainUrl = Globals().chainUrl;
  if (chainUrl == '') return null;
  final phrase = await getPhrase();
  if (phrase != null) {
    final wallet = await Stellar.Client.createFromMnemonic(
        Stellar.NetworkType.PUBLIC, phrase);
    final privateKey = wallet.privateKey;
    if (privateKey != null) {
      final hexSecret = hex.encode(privateKey.toList().sublist(0, 32));
      final tfchainClient = TFChain.Client(chainUrl, '0x$hexSecret', "sr25519");
      await tfchainClient.connect();
      final twinId = await tfchainClient.twins.getMyTwinId();
      await tfchainClient.disconnect();
      return twinId;
    }
  }
  return null;
}
