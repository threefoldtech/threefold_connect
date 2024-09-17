import 'package:flutter/foundation.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:stellar_client/stellar_client.dart' as Stellar;
import 'package:convert/convert.dart';
import 'package:tfchain_client/tfchain_client.dart' as TFChain;

Future<int?> getMyTwinId() async {
  final chainUrl = Globals().chainUrl;
  if (chainUrl == '') return null;
  final phrase = await getPhrase();
  if (phrase != null) {
    return await compute((void _) async {
      final wallet =
          await Stellar.Client.fromMnemonic(Stellar.NetworkType.PUBLIC, phrase);
      final privateKey = wallet.privateKey;
      if (privateKey != null) {
        final hexSecret = hex.encode(privateKey.toList().sublist(0, 32));
        final tfchainClient =
            TFChain.Client(chainUrl, '0x$hexSecret', "sr25519");
        await tfchainClient.connect();
        final twinId = await tfchainClient.twins.getMyTwinId();
        await tfchainClient.disconnect();
        return twinId;
      }
      return null;
    }, null);
  }
  return null;
}

Future<double> getBalance(String chainUrl, String address) async {
  final tfchainQueryClient = TFChain.QueryClient(chainUrl);
  await tfchainQueryClient.connect();
  final balances = await tfchainQueryClient.balances.get(address: address);
  return balances!.data.free / BigInt.from(10).pow(7);
}
