import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/wallet_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final List<Wallet> wallets = [
    Wallet(
        name: 'Daily',
        stellarSecret: 'stsecret',
        stellarAddress: 'staddress',
        stellarBalance: '10.54',
        tfchainSecret: 'tfsecret',
        tfchainAddress: 'tfaddress',
        tfchainBalance: '43.26')
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Wallet',
      content: ListView(
        children: [
          for (final wallet in wallets) WalletCardWidget(wallet: wallet)
        ],
      ),
    );
  }
}
