import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class WalletReceiveScreen extends StatefulWidget {
  const WalletReceiveScreen({super.key, required this.wallet});
  final Wallet wallet;

  @override
  State<WalletReceiveScreen> createState() => _WalletReceiveScreenState();
}

class _WalletReceiveScreenState extends State<WalletReceiveScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}