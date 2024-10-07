import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/wallets/add_wallet.dart';
import 'package:threebotlogin/widgets/wallets/wallet_card.dart';
import 'package:hashlib/hashlib.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool loading = true;
  bool failed = false;
  List<Wallet> wallets = [];

  onDeleteWallet(String name) {
    wallets = wallets.where((w) => w.name != name).toList();
    setState(() {});
  }

  onEditWallet(String oldName, String newName) {
    for (final w in wallets) {
      if (w.name == oldName) {
        w.name = newName;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    listMyWallets();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: handle empty wallets
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
    } else if (failed) {
      mainWidget = Center(
        child: Text(
          'Something went wrong.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onBackground),
        ),
      );
    } else {
      mainWidget = ListView(
        children: [
          for (final wallet in wallets)
            WalletCardWidget(
              wallet: wallet,
              allWallets: wallets,
              onDeleteWallet: onDeleteWallet,
              onEditWallet: onEditWallet,
            )
        ],
      );
    }

    return LayoutDrawer(
      titleText: 'Wallet',
      content: mainWidget,
      appBarActions: loading && !failed
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
    try {
      final myWallets = await listWallets();
      wallets.addAll(myWallets);
      if (wallets.isEmpty) {
        await _addInitialWallet();
      }
    } catch (e) {
      failed = true;
      print('Failed to get wallets due to $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to load wallets',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  _openAddWalletOverlay() {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewWallet(
              onAddWallet: _addWallet,
              wallets: wallets,
            ));
  }

  Future<void> _addInitialWallet() async {
    const walletName = 'Daily';
    final derivedSeed = await getDerivedSeed(WalletConfig().appId());
    final seedList = derivedSeed.toList();
    seedList.addAll([0, 0, 0, 0, 0, 0, 0, 0]); // instead of sia binary encoder
    final walletSecret = Blake2b(32).hex(seedList);
    final wallet = await loadAddedWallet(walletName, walletSecret);
    await addWallet(walletName, walletSecret, type: WalletType.NATIVE);
    wallets.add(wallet);
  }

  void _addWallet(Wallet wallet) {
    wallets.add(wallet);
    setState(() {});
  }
}
