import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:stellar_client/stellar_client.dart' as Stellar;
import 'package:tfchain_client/tfchain_client.dart' as TFChain;
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';

Future<FlutterPkid> _getPkidClient() async {
  Uint8List seed = await getDerivedSeed(WalletConfig().appId());
  final mnemonic = bip39.entropyToMnemonic(hex.encode(seed));
  FlutterPkid client = await getPkidClient(seedPhrase: mnemonic);
  return client;
}

Future<Map<int, dynamic>> _getPkidWallets() async {
  FlutterPkid client = await _getPkidClient();
  final pKidResult = await client.getPKidDoc('purse');
  final result =
      pKidResult.containsKey('data') && pKidResult.containsKey('success')
          ? jsonDecode(pKidResult['data'])
          : {};
  // TODO: add pkid wallet model
  Map<int, dynamic> dataMap = result.asMap();
  return dataMap;
}

Future<List<Wallet>> listWallets() async {
  Map<int, dynamic> dataMap = await _getPkidWallets();
  final String chainUrl = Globals().chainUrl;
  final List<Wallet> wallets = await compute((void _) async {
    final List<Future<Wallet>> walletFutures = [];
    for (final w in dataMap.values) {
      final String walletSeed = w['seed'];
      final String walletName = w['name'];
      final WalletType walletType =
          w['type'] == 'NATIVE' ? WalletType.Native : WalletType.Imported;
      final walletFuture =
          loadWallet(walletName, walletSeed, walletType, chainUrl);
      walletFutures.add(walletFuture);
    }
    return await Future.wait(walletFutures);
  }, null);

  return wallets;
}

Future<Wallet> loadWallet(String walletName, String walletSeed,
    WalletType walletType, String chainUrl) async {
  Stellar.Client stellarClient;
  TFChain.Client tfchainClient;
  if (' '.allMatches(walletSeed).length == 11) {
    tfchainClient = TFChain.Client(chainUrl, walletSeed, "sr25519");
    final entropy = bip39.mnemonicToEntropy(walletSeed);
    final seed = entropy.padRight(64, "0");
    stellarClient =
        Stellar.Client.fromSecretSeedHex(Stellar.NetworkType.PUBLIC, seed);
  } else if (' '.allMatches(walletSeed).length == 23) {
    stellarClient = await Stellar.Client.fromMnemonic(
        Stellar.NetworkType.PUBLIC, walletSeed);
    final hexSecret =
        hex.encode(stellarClient.privateKey!.toList().sublist(0, 32));
    tfchainClient = TFChain.Client(chainUrl, '0x$hexSecret', "sr25519");
  } else {
    stellarClient = Stellar.Client.fromSecretSeedHex(
        Stellar.NetworkType.PUBLIC, walletSeed);
    final hexSecret =
        hex.encode(stellarClient.privateKey!.toList().sublist(0, 32));
    tfchainClient = TFChain.Client(chainUrl, '0x$hexSecret', "sr25519");
  }
  String stellarBalance = '0';
  try {
    final stellarBalances = await stellarClient.getBalance();
    for (final balance in stellarBalances) {
      if (balance.assetCode == 'TFT') {
        stellarBalance = balance.balance;
      }
    }
  } catch (e) {
    print("Couldn't load the account balance.");
  }
  await tfchainClient.connect();
  final tfchainBalance =
      (await tfchainClient.balances.getMyBalance())!.data.free /
          BigInt.from(10).pow(7);
  final wallet = Wallet(
    name: walletName,
    stellarSecret: stellarClient.secretSeed,
    stellarAddress: stellarClient.accountId,
    tfchainSecret: tfchainClient.mnemonicOrSecretSeed,
    tfchainAddress: tfchainClient.address,
    stellarBalance: stellarBalance,
    tfchainBalance:
        tfchainBalance.toString() == '0.0' ? '0' : tfchainBalance.toString(),
    type: walletType,
  );
  return wallet;
}

Future<void> addWallet(String walletName, String walletSecret) async {
  Map<int, dynamic> wallets = await _getPkidWallets();
  Map<int, dynamic> newWallets = {};
  int i = 0;
  for (final wallet in wallets.values) {
    newWallets[i] = wallet;
    i++;
  }
  newWallets[i] = {
    'type': 'IMPORTED',
    'index': -1,
    'name': walletName,
    'seed': walletSecret
  };
  await _saveWalletsToPkid(newWallets);
}

Future<void> editWallet(String oldName, String newName) async {
  Map<int, dynamic> wallets = await _getPkidWallets();
  int key = -1;
  for (final entry in wallets.entries) {
    if (entry.value['name'] == oldName) {
      key = entry.key;
    }
  }
  if (key >= 0) {
    final wallet = wallets[key];
    wallet['name'] = newName;
    wallets[key] = wallet;
    await _saveWalletsToPkid(wallets);
  }
}

Future<void> deleteWallet(String walletName) async {
  Map<int, dynamic> wallets = await _getPkidWallets();
  Map<int, dynamic> newWallets = {};
  int i = 0;
  for (final wallet in wallets.values) {
    if (wallet['name'] == walletName) continue;
    newWallets[i] = wallet;
    i++;
  }
  await _saveWalletsToPkid(newWallets);
}

Future<void> _saveWalletsToPkid(Map<int, dynamic> wallets) async {
  FlutterPkid client = await _getPkidClient();
  await client.setPKidDoc('purse', json.encode(wallets));
}
