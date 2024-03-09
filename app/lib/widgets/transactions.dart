import 'package:flutter/material.dart';

class WalletTransactionsWidget extends StatelessWidget {
  const WalletTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Transactions',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
    );
  }
}
