import 'package:flutter/material.dart';
import 'package:stellar_client/models/transaction.dart';

class TransactionDetails extends StatelessWidget {
  final PaymentTransaction transaction;

  const TransactionDetails({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  label == 'Type'
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: value == 'Receive'
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: value == 'Receive'
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                                  )),
                        )
                      : Text(value,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          buildDetailRow('From', transaction.from),
          const Divider(),
          buildDetailRow('To', transaction.to),
          const Divider(),
          buildDetailRow('Type', transaction.type.name),
          const Divider(),
          buildDetailRow(
              'Amount', double.parse(transaction.amount).toStringAsFixed(3)),
          const Divider(),
          buildDetailRow('Asset', transaction.asset),
          const Divider(),
          buildDetailRow('Date', transaction.date),
          const Divider(),
          buildDetailRow('Memo', transaction.memo),
          const Divider(),
          buildDetailRow('Transaction Hash', transaction.hash),
          const Divider(),
        ],
      ),
    );
  }
}
