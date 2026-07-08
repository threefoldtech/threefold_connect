import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/wallets/transactions.dart';
import 'package:threebotlogin/screens/wallets/wallet_assets.dart';
import 'package:threebotlogin/screens/wallets/contracts.dart';
import 'package:threebotlogin/screens/wallets/wallet_info.dart';

class WalletDetailsScreen extends ConsumerStatefulWidget {
  const WalletDetailsScreen({super.key, required this.wallet});
  final Wallet wallet;

  @override
  ConsumerState<WalletDetailsScreen> createState() =>
      _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends ConsumerState<WalletDetailsScreen> {
  int currentScreenIndex = 0;

  void _selectScreen(int index) {
    setState(() {
      currentScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    ref.watch(walletsNotifier).firstWhere((w) => w.name == widget.wallet.name);
    if (currentScreenIndex == 1) {
      content = WalletTransactionsWidget(
        wallet: widget.wallet,
      );
    } else if (currentScreenIndex == 2) {
      content = WalletContractsWidget(wallet: widget.wallet);
    } else if (currentScreenIndex == 3) {
      content = WalletDetailsWidget(wallet: widget.wallet);
    } else {
      content = WalletAssetsWidget(
        wallet: widget.wallet,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet.name),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectScreen,
        currentIndex: currentScreenIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: 'Assets'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          BottomNavigationBarItem(
              icon: Icon(Icons.description), label: 'Contracts'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
        ],
      ),
      body: content,
    );
  }
}
