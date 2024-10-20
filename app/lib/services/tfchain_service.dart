import 'dart:convert';

import 'package:tfchain_client/generated/dev/types/tfchain_support/types/farm.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:tfchain_client/tfchain_client.dart' as TFChain;
import 'package:tfchain_client/models/dao.dart';
import 'package:tfchain_client/generated/dev/types/pallet_dao/proposal/dao_votes.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:hashlib/hashlib.dart' as hashlib;

Future<int?> getMyTwinId() async {
  final chainUrl = Globals().chainUrl;
  if (chainUrl == '') return null;
  final derivedSeed = await getDerivedSeed(WalletConfig().appId());
  final seedList = derivedSeed.toList();
  seedList.addAll([0, 0, 0, 0, 0, 0, 0, 0]); // instead of sia binary encoder
  final seed = hashlib.Blake2b(32).hex(seedList);
  final twinId = getTwinId('0x$seed');
  if (twinId == 0) return null;
  return twinId;
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

Future<int> getTwinIdByClient(TFChain.Client client) async {
  await client.connect();
  final twinId = await client.twins.getMyTwinId();
  return twinId ?? 0;
}

Future<int> getTwinId(String seed) async {
  final chainUrl = Globals().chainUrl;
  final client = TFChain.Client(chainUrl, seed, 'sr25519');
  return getTwinIdByClient(client);
}

Future<Map<String, List<Proposal>>> getProposals() async {
  try {
    final chainUrl = Globals().chainUrl;
    final client = TFChain.QueryClient(chainUrl);
    await client.connect();
    final proposals = await client.dao.get();
    return proposals;
  } catch (e) {
    throw Exception('Failed to get dao proposals due to $e');
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
    throw Exception('Failed to get dao proposals votes due to $e');
  }
}

Future<DaoVotes> vote(bool vote, String hash, int farmId, String seed) async {
  try {
    final chainUrl = Globals().chainUrl;
    final client = TFChain.Client(chainUrl, seed, 'sr25519');
    client.connect();
    final daoVotes =
        await client.dao.vote(farmId: farmId, hash: hash, approve: vote);
    return daoVotes;
  } catch (e) {
    throw Exception('Failed to vote due to $e');
  }
}

_activateAccount(String tfchainSeed) async {
  final activationUrl = Globals().activationUrl;
  final chainUrl = Globals().chainUrl;
  final client = TFChain.Client(chainUrl, tfchainSeed, 'sr25519');
  await client.connect();

  final activationUri = Uri.parse(activationUrl);
  final activationResponse = await http
      .post(activationUri, body: {'substrateAccountID': client.address});
  if (activationResponse.statusCode != 200) {
    throw Exception('Failed to activate account');
  }
  final documentUrl = Globals().termsAndConditionsUrl;
  final documentUri = Uri.parse(documentUrl);
  final response = await http.get(documentUri);
  final bytes = utf8.encode(response.body);
  final digest = md5.convert(bytes);
  final hashString =
      digest.bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  await client.termsAndConditions
      .accept(documentLink: documentUrl, documentHash: hashString.codeUnits);
  final relayUrl = Globals().relayUrl;
  await client.twins.create(relay: relayUrl, pk: []);
}

Future<Farm?> createFarm(
    String name, String tfchainSeed, String stellarAddress) async {
  try {
    final chainUrl = Globals().chainUrl;
    final client = TFChain.Client(chainUrl, tfchainSeed, 'sr25519');
    client.connect();
    final twinId = await getTwinIdByClient(client);
    if (twinId == 0) {
      await _activateAccount(tfchainSeed);
    }
    final farmId = await client.farms.create(name: name, publicIps: []);
    final farm = await client.farms.get(id: farmId!);
    await client.farms
        .addStellarAddress(farmId: farmId, stellarAddress: stellarAddress);
    return farm;
  } catch (e) {
    throw Exception('Failed to create farm due to $e');
  }
}

Future<void> transfer(String secret, String dest, String amount) async {
  final chainUrl = Globals().chainUrl;
  final client = TFChain.Client(chainUrl, secret, 'sr25519');
  client.connect();
  await client.balances.transfer(address: dest, amount: BigInt.parse(amount));
}
