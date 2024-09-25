import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class WalletSendScreen extends StatefulWidget {
  const WalletSendScreen({super.key, required this.wallet});
  final Wallet wallet;
  @override
  State<WalletSendScreen> createState() => _WalletSendScreenState();
}

class _WalletSendScreenState extends State<WalletSendScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}