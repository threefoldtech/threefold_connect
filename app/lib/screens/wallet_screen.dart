import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      appBarActions: loading
          ? []
          : [
              IconButton(
                  onPressed: _openAddWalletOverlay,
                  icon: const Icon(
                    Icons.add,
                  ))
            ],
    );
  }

  listMyWallets() async {
    setState(() {
      loading = true;
    });
    // TODO: handle empty list wallets
    // TODO: show error on failure
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
              wallets: wallets,
            ));
  }

  void _addWallet(Wallet wallet) {
    wallets.add(wallet);
    setState(() {});
  }
}
