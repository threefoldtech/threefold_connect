import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/wallet_card.dart';
import 'package:stellar_client/stellar_client.dart' as Stellar;
import 'package:tfchain_client/tfchain_client.dart' as TFChain;
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool loading = true;
  final List<Wallet> wallets = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listWallets();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget;
    if (loading) {
      mainWidget = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(
            "Loading Wallets...",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else {
      mainWidget = ListView(
        children: [
          for (final wallet in wallets) WalletCardWidget(wallet: wallet)
        ],
      );
    }

    return LayoutDrawer(titleText: 'Wallet', content: mainWidget);
  }

  listWallets() async {
    Uint8List seed = await getDerivedSeed(WalletConfig().appId());
    final mnemonic = bip39.entropyToMnemonic(hex.encode(seed));
    FlutterPkid client = await getPkidClient(seedPhrase: mnemonic);

    final pKidResult = await client.getPKidDoc("purse");
    final result =
        pKidResult.containsKey('data') && pKidResult.containsKey('success')
            ? jsonDecode(pKidResult['data'])
            : {};

    Map<int, dynamic> dataMap = result.asMap();
    final chainUrl = Globals().chainUrl;
    for (final w in dataMap.values) {
      Stellar.Client stellarClient;
      TFChain.Client tfchainClient;
      if (" ".allMatches(w["seed"]).length == 11) {
        tfchainClient = TFChain.Client(chainUrl, w["seed"], "sr25519");
        final entropy = bip39.mnemonicToEntropy(w["seed"]);
        final seed = entropy.padRight(64, "0");
        stellarClient =
            Stellar.Client.fromSecretSeedHex(Stellar.NetworkType.PUBLIC, seed);
      } else if (" ".allMatches(w["seed"]).length == 23) {
        stellarClient = await Stellar.Client.fromMnemonic(
            Stellar.NetworkType.PUBLIC, w["seed"]);
        final hexSecret =
            hex.encode(stellarClient.privateKey!.toList().sublist(0, 32));
        tfchainClient = TFChain.Client(chainUrl, '0x$hexSecret', "sr25519");
      } else {
        stellarClient = Stellar.Client.fromSecretSeedHex(
            Stellar.NetworkType.PUBLIC, w["seed"]);
        final hexSecret =
            hex.encode(stellarClient.privateKey!.toList().sublist(0, 32));
        tfchainClient = TFChain.Client(chainUrl, '0x$hexSecret', "sr25519");
      }
      String stellarBalance = "0.0";
      try {
        final stellarBalances = await stellarClient.getBalance();
        for (final balance in stellarBalances) {
          if (balance.assetCode == "TFT") ;
          stellarBalance = balance.balance;
        }
      } catch (e) {
        print("Couldn't load the account balance.");
      }

      await tfchainClient.connect();
      final tfchainBalance =
          (await tfchainClient.balances.getMyBalance())!.data.free /
              BigInt.from(10).pow(7);
      final wallet = Wallet(
        name: w["name"],
        stellarClient: stellarClient,
        tfchainClient: tfchainClient,
        stellarBalance: stellarBalance,
        tfchainBalance: tfchainBalance.toString(),
        type: w["type"] == "Native" ? WalletType.Native : WalletType.Imported,
      );
      wallets.add(wallet);
    }
    setState(() {
      loading = false;
    });
  }
}
