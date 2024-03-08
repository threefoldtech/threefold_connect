import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget({super.key, required this.wallet});
  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            wallet.name,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Stellar',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              const Spacer(),
              Text(
                '${wallet.stellarBalance} TFT',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'TFChain',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              const Spacer(),
              Text(
                '${wallet.tfchainBalance} TFT',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
