import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/add_wallet.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/wallet_card.dart';

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
    super.initState();
    listMyWallets();
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
            'Loading Wallets...',
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

    return LayoutDrawer(
      titleText: 'Wallet',
      content: mainWidget,
      appBarActions: [
        IconButton(
            // TODO: disable clicks till the wallets are loading.
            onPressed: _openAddWalletOverlay,
            icon: const Icon(Icons.add))
      ],
    );
  }

  listMyWallets() async {
    setState(() {
      loading = true;
    });
    final myWallets = await listWallets();
    wallets.addAll(myWallets);
    setState(() {
      loading = false;
    });
  }

  _openAddWalletOverlay() {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewWallet(
              onAddWallet: _addWallet,
            ));
  }

  Future<void> _addWallet(SimpleWallet wallet) async {
    setState(() {
      loading = true;
    });

    final w = await loadAddWallet(wallet.name, wallet.secret);
    wallets.add(w);

    setState(() {
      loading = false;
    });
  }
}

Future<Wallet> loadAddWallet(String walletName, String walletSecret) async {
  final chainUrl = Globals().chainUrl;
  final Wallet wallet = await compute((void _) async {
    final wallet = await loadWallet(
        walletName, walletSecret, WalletType.Imported, chainUrl);
    return wallet;
  }, null);
  return wallet;
}
