import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/wallets/wallet_details.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget(
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
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => WalletDetailsScreen(
              wallet: wallet,
              allWallets: allWallets,
              onDeleteWallet: onDeleteWallet,
              onEditWallet: onEditWallet,
            ),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wallet.name,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              const SizedBox(height: 10),
              if (double.parse(wallet.stellarBalance) >= 0)
                Row(
                  children: [
                    SizedBox(
                        width: 35,
                        child: Image.asset(
                          'assets/tft_icon.png',
                          color: Theme.of(context).colorScheme.onBackground,
                        )),
                    Text(
                      'Stellar',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${wallet.stellarBalance} TFT',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                  ],
                ),
              if (double.parse(wallet.tfchainBalance) >= 0)
                Row(
                  children: [
                    SizedBox(
                        width: 35,
                        child: Image.asset(
                          'assets/tft_icon.png',
                          fit: BoxFit.contain,
                          color: Theme.of(context).colorScheme.onBackground,
                        )),
                    Text(
                      'TFChain',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${wallet.tfchainBalance} TFT',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
