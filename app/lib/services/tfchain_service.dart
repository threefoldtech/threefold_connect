import 'package:flutter/foundation.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:stellar_client/stellar_client.dart' as Stellar;
import 'package:convert/convert.dart';
import 'package:tfchain_client/tfchain_client.dart' as TFChain;
import 'package:tfchain_client/models/dao.dart';
import 'package:tfchain_client/generated/dev/types/pallet_dao/proposal/dao_votes.dart';

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

Future<double> getBalanceByClient(TFChain.Client client) async {
  await client.connect();
  final balance = (await client.balances.getMyBalance())!.data.free;
  return balance / BigInt.from(10).pow(7);
}

Future<int?> getTwinIdByClient(TFChain.Client client) async {
  await client.connect();
  final twinId = await client.twins.getMyTwinId();
  return twinId;
}

Future<Map<String, List<Proposal>>> getProposals() async {
  try {
    final chainUrl = Globals().chainUrl;
    final client = TFChain.QueryClient(chainUrl);
    await client.connect();
    final proposals = await client.dao.get();
    return proposals;
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<DaoVotes> getProposalVotes(String hash) async {
  try {
    final chainUrl = Globals().chainUrl;
    final client = TFChain.QueryClient(chainUrl);
    await client.connect();
    final votes = await client.dao.getProposalVotes(hash: hash);
    return votes;
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<DaoVotes> vote(bool vote, String hash, int farmId) async {
  try {
    final chainUrl = Globals().chainUrl;
    // TODO: set the mnrmonic based on the wallet
    final client = TFChain.Client(chainUrl, "mnemonic", 'sr25519');
    client.connect();
    final daoVotes =
        await client.dao.vote(farmId: farmId, hash: hash, approve: vote);
    return daoVotes;
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}
