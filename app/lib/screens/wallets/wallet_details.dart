import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/wallets/transactions.dart';
import 'package:threebotlogin/screens/wallets/wallet_assets.dart';
import 'package:threebotlogin/screens/wallets/wallet_info.dart';

class WalletDetailsScreen extends StatefulWidget {
  const WalletDetailsScreen(
      {super.key,
      required this.wallet,
      required this.allWallets,
      required this.onDeleteWallet,
      required this.onEditWallet});
  final Wallet wallet;
  final List<Wallet> allWallets;
  final void Function(String name) onDeleteWallet;
  final void Function(String oldName, String newName) onEditWallet;

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

  void _onEditWallet(String oldName, String newName) {
    widget.wallet.name = newName;
    widget.onEditWallet(oldName, newName);
    setState(() {});
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
        onDeleteWallet: widget.onDeleteWallet,
        onEditWallet: _onEditWallet,
      );
    } else {
      content = WalletAssetsWidget(
        allWallets: widget.allWallets,
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
