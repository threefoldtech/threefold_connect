import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/wallets/transaction_details.dart';
import 'package:threebotlogin/widgets/wallets/arrow_inward.dart';

class TransactionWidget extends StatelessWidget {
  final Transaction transaction;

  const TransactionWidget({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(
              transaction: transaction,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: transaction.type == TransactionType.Receive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
              child: transaction.type == TransactionType.Receive
                  ? ArrowInward(
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : Icon(
                      Icons.arrow_outward,
                      color: Theme.of(context).colorScheme.onError,
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.hash,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            'TFT ${double.parse(transaction.amount).toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: transaction.type ==
                                          TransactionType.Receive
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.error,
                                )),
                      ),
                      Text(transaction.date,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: transaction.status
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(transaction.status ? 'Successful' : 'Failed',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: transaction.status
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
