import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class WalletSelectionSheet extends StatelessWidget {
  final List<PkidWallet> wallets;
  final PkidWallet? selectedWallet;
  final void Function(PkidWallet) onWalletSelected;

  const WalletSelectionSheet({
    super.key,
    required this.wallets,
    required this.selectedWallet,
    required this.onWalletSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Wallet',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer
            ),
          ),
          const SizedBox(height: 12),
          ...wallets.map((wallet) => ListTile(
                title: Text(wallet.name),
                trailing: wallet.name == selectedWallet?.name
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => onWalletSelected(wallet),
              )),
        ],
      ),
    );
  }
}
