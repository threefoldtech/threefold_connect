import 'package:flutter/material.dart';

class WalletBalanceWidget extends StatelessWidget {
  const WalletBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Balances',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
    );
  }
}
