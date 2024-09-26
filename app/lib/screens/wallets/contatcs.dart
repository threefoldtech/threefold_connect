import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen(
      {super.key, required this.wallets, required this.onSelectToAddress});

  final List<Wallet> wallets;
  final void Function(String address) onSelectToAddress;

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView(children: [
        for (final wallet in widget.wallets)
          InkWell(
            onTap: () {
              widget.onSelectToAddress(wallet.stellarAddress);
              Navigator.of(context).pop();
            },
            child: ListTile(
              title: Text(wallet.name),
            ),
          ),
      ]),
    );
  }
}
