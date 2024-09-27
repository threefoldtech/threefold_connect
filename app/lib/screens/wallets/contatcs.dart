import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/widgets/wallets/contact_card.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen(
      {super.key,
      required this.chainType,
      required this.currentWalletAddress,
      required this.wallets,
      required this.onSelectToAddress});

  final ChainType chainType;
  final String currentWalletAddress;
  final List<Wallet> wallets;
  final void Function(String address) onSelectToAddress;

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Wallet> wallets = widget.wallets.where((w) {
      if (widget.chainType ==ChainType.Stellar && w.stellarAddress != widget.currentWalletAddress){
        return true;
      }
      if (widget.chainType ==ChainType.TFChain && w.tfchainAddress != widget.currentWalletAddress){
        return true;
      }
      return false;
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView(children: [
        for (final wallet in wallets)
          InkWell(
              onTap: () {
                widget.chainType == ChainType.Stellar
                    ? widget.onSelectToAddress(wallet.stellarAddress)
                    : widget.onSelectToAddress(wallet.tfchainAddress);

                Navigator.of(context).pop();
              },
              child: ContactCardWidget(
                name: wallet.name,
                address: widget.chainType == ChainType.Stellar
                    ? wallet.stellarAddress
                    : wallet.tfchainAddress,
              )),
      ]),
    );
  }
}
