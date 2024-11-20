import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class SelectTransactionWidget extends StatelessWidget {
  const SelectTransactionWidget(
      {super.key,
      required this.transactionType,
      required this.onTransactionChange,
      required this.hideDeposit});
  final void Function(TransactionType transactionType) onTransactionChange;
  final TransactionType transactionType;
  final bool hideDeposit;

  Widget _optionButton(BuildContext context, String label, double width,
      bool active, void Function() onPressed) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          maximumSize: Size.fromWidth(width),
          backgroundColor:
              active ? colorScheme.primaryContainer : colorScheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(
                  color: active
                      ? colorScheme.primaryContainer
                      : colorScheme.secondaryContainer))),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: active
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _optionButton(context, 'Withdraw', width / 2,
              transactionType == TransactionType.Withdraw, () {
            onTransactionChange(TransactionType.Withdraw);
          }),
          if (!hideDeposit)
            _optionButton(context, 'Deposit', width / 2,
                transactionType == TransactionType.Deposit, () {
              onTransactionChange(TransactionType.Deposit);
            }),
        ],
      ),
    );
  }
}
