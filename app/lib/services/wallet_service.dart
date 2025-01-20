import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:gridproxy_client/models/farms.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:stellar_client/stellar_client.dart' as Stellar;
import 'package:tfchain_client/tfchain_client.dart' as TFChain;
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:threebotlogin/services/stellar_service.dart' as StellarService;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;
import 'package:hashlib/hashlib.dart';

Future<FlutterPkid> _getPkidClient() async {
  Uint8List seed = await getDerivedSeed(WalletConfig().appId());
  final mnemonic = bip39.entropyToMnemonic(hex.encode(seed));
  FlutterPkid client = await getPkidClient(seedPhrase: mnemonic);
  return client;
}

Future<List<PkidWallet>> getPkidWallets() async {
  FlutterPkid client = await _getPkidClient();
  Map<String, dynamic> pKidResult;
  try {
    pKidResult = await client.getPKidDoc('purse');
    if (pKidResult.containsKey('error')) {
      logger.e('Error in pKidResult : ${pKidResult['error']}');
      throw Exception('Error fetching wallets');
    }
  } catch (e) {
    logger.e('Error while requesting pkidWallets');
    throw Exception('Error fetching wallets');
  }
  final result =
      pKidResult.containsKey('data') && pKidResult.containsKey('success')
          ? jsonDecode(pKidResult['data'])
          : {};

  if (result.isEmpty) {
    return [];
  }

  Map<int, dynamic> dataMap = result.asMap();
  final pkidWallets =
      dataMap.values.map((e) => PkidWallet.fromJson(e)).toSet().toList();
  return pkidWallets;
}

Future<List<Wallet>> listWallets() async {
  List<PkidWallet> pkidWallets = [];
  try {
    pkidWallets = await getPkidWallets();
  } catch (e) {
    logger.e('Error fetching PKID wallets: $e');
    throw Exception('Error fetching wallets');
  }
  final String chainUrl = Globals().chainUrl;
  final List<Wallet> wallets = await compute((void _) async {
    final List<Future<Wallet>> walletFutures = [];
    for (final w in pkidWallets) {
      final walletFuture = loadWallet(w.name, w.seed, w.type, chainUrl);
      walletFutures.add(walletFuture);
    }
    return await Future.wait(walletFutures);
  }, null);

  return wallets;
}

Future<(Stellar.Client, TFChain.Client)> loadWalletClients(String walletName,
    String walletSeed, WalletType walletType, String chainUrl) async {
  Stellar.Client stellarClient;
  TFChain.Client tfchainClient;
  if (' '.allMatches(walletSeed).length == 11) {
    tfchainClient = TFChain.Client(chainUrl, walletSeed, 'sr25519');
    final entropy = bip39.mnemonicToEntropy(walletSeed);
    final seed = entropy.padRight(64, '0');
    stellarClient =
        Stellar.Client.fromSecretSeedHex(Stellar.NetworkType.PUBLIC, seed);
  } else if (' '.allMatches(walletSeed).length == 23) {
    final entropy = bip39.mnemonicToEntropy(walletSeed);
    final seedList = hex.decode(entropy).toList();
    seedList.addAll([0, 0, 0, 0, 0, 0, 0, 0]); // instead of sia binary encoder
    final seed = Blake2b(32).hex(seedList);

    stellarClient =
        Stellar.Client.fromSecretSeedHex(Stellar.NetworkType.PUBLIC, seed);
    tfchainClient = TFChain.Client(chainUrl, '0x$seed', 'sr25519');
  } else if (StellarService.isValidStellarSecret(walletSeed)) {
    stellarClient = Stellar.Client(Stellar.NetworkType.PUBLIC, walletSeed);
    final hexSecret =
        hex.encode(stellarClient.privateKey!.toList().sublist(0, 32));
    tfchainClient = TFChain.Client(chainUrl, '0x$hexSecret', 'sr25519');
  } else {
    if (walletSeed.startsWith(RegExp(r'0[xX]'))) {
      walletSeed = walletSeed.substring(2);
    }
    stellarClient = Stellar.Client.fromSecretSeedHex(
        Stellar.NetworkType.PUBLIC, walletSeed);
    final hexSecret =
        hex.encode(stellarClient.privateKey!.toList().sublist(0, 32));
    tfchainClient = TFChain.Client(chainUrl, '0x$hexSecret', 'sr25519');
  }
  return (stellarClient, tfchainClient);
}

Future<Wallet> loadWallet(String walletName, String walletSeed,
    WalletType walletType, String chainUrl) async {
  final (stellarClient, tfchainClient) =
      await loadWalletClients(walletName, walletSeed, walletType, chainUrl);
  final balances = await Future.wait([
    StellarService.getBalanceByClient(stellarClient),
    TFChainService.getBalanceByClient(tfchainClient)
  ]);
  final stellarBalance = balances.first.toString();
  final tfchainBalance =
      balances.last.toString() == '0.0' ? '0' : balances.last.toString();
  final wallet = Wallet(
    name: walletName,
    stellarSecret: stellarClient.secretSeed,
    stellarAddress: stellarClient.accountId,
    tfchainSecret: tfchainClient.mnemonicOrSecretSeed,
    tfchainAddress: tfchainClient.address,
    stellarBalance: stellarBalance,
    tfchainBalance: tfchainBalance,
    type: walletType,
  );
  return wallet;
}

Future<void> addWallet(String walletName, String walletSecret,
    {WalletType type = WalletType.IMPORTED}) async {
  List<PkidWallet> wallets = await getPkidWallets();
  wallets.any((w) => w.seed == walletSecret)
      ? throw Exception('Wallet already exists.')
      : wallets.add(PkidWallet(
          name: walletName,
          index: type == WalletType.NATIVE ? 0 : -1,
          seed: walletSecret,
          type: type));

  await saveWalletsToPkid(wallets);
}

Future<void> editWallet(String oldName, String newName) async {
  List<PkidWallet> wallets = await getPkidWallets();
  for (final w in wallets) {
    if (w.name == oldName) {
      w.name = newName;
      break;
    }
  }
  await saveWalletsToPkid(wallets);
}

Future<void> deleteWallet(String walletName) async {
  List<PkidWallet> wallets = await getPkidWallets();
  wallets = wallets.where((w) => w.name != walletName).toList();
  await saveWalletsToPkid(wallets);
}

Future<void> saveWalletsToPkid(List<PkidWallet> wallets) async {
  FlutterPkid client = await _getPkidClient();
  final encodedWallets = json.encode(wallets.map((w) => w.toMap()).toList());
  await client.setPKidDoc('purse', encodedWallets);
}

Future<Map<int, Map<String, String>>> getWalletTwinId(String walletName,
    String walletSeed, WalletType walletType, String chainUrl) async {
  final (stellarClient, tfchainClient) =
      await loadWalletClients(walletName, walletSeed, walletType, chainUrl);
  final twinId = await TFChainService.getTwinIdByClient(tfchainClient);
  final Map<int, Map<String, String>> twinIdWallet = {
    twinId: {
      'tfchainSeed': tfchainClient.mnemonicOrSecretSeed,
      'name': walletName,
      'stellarAddress': stellarClient.accountId
    }
  };
  return twinIdWallet;
}

Future<List<Farm>> getDaoFarms(List<Wallet> wallets) async {
  final Map<int, Wallet> twinIdWallets = {};

  final twinIdFutures = wallets.map((w) async {
    final twinId = await TFChainService.getTwinId(w.tfchainSecret);
    if (twinId != 0) {
      twinIdWallets[twinId] = w;
    }
  }).toList();

  await Future.wait(twinIdFutures);

  final farms =
      await getFarmsByTwinIds(twinIdWallets.keys.toList(), hasUpNode: true);
  return farms;
}

Future<void> initializeWallet(String stellarSecret, String tfchainSeed) async {
  await StellarService.initialize(stellarSecret);
  await TFChainService.activateAccount(tfchainSeed);
}
