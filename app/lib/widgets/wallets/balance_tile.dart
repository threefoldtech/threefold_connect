import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class WalletBalanceTileWidget extends StatelessWidget {
  const WalletBalanceTileWidget({
    super.key,
    required this.balance,
    required this.name,
    required this.loading,
  });
  final String balance;
  final ChainType name;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      leading: SizedBox(
        width: 25,
        child: Image.asset(
          name == ChainType.TFChain
              ? 'assets/tf_chain.png'
              : 'assets/stellar.png',
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      title: Text(
        name.name,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
      trailing: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ))
          : Text(
              '$balance TFT',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
    );
  }
}
