import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/wallets/transactions.dart';
import 'package:threebotlogin/screens/wallets/wallet_assets.dart';
import 'package:threebotlogin/screens/wallets/wallet_info.dart';

class WalletDetailsScreen extends StatefulWidget {
  const WalletDetailsScreen({super.key, required this.wallet});
  final Wallet wallet;

  @override
  State<WalletDetailsScreen> createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> {
  int currentScreenIndex = 0;

  void _selectScreen(int index) {
    setState(() {
      currentScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (currentScreenIndex == 1) {
      content = WalletTransactionsWidget(
        wallet: widget.wallet,
      );
    } else if (currentScreenIndex == 2) {
      content = WalletDetailsWidget(
        wallet: widget.wallet,
      );
    } else {
      content = WalletAssetsWidget(
        wallet: widget.wallet,
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.wallet.name)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectScreen,
        currentIndex: currentScreenIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: 'Assets'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
        ],
      ),
      body: content,
    );
  }
}
