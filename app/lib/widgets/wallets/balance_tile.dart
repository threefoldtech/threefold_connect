import 'package:flutter/material.dart';

class WalletBalanceTileWidget extends StatelessWidget {
  const WalletBalanceTileWidget({
    super.key,
    required this.balance,
    required this.name,
  });
  final String balance;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      leading: Image.asset(
        'assets/tft_icon.png',
        fit: BoxFit.cover,
        color: Theme.of(context).colorScheme.onBackground,
        height: 50,
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
      trailing: Text(
        '$balance TFT',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}
