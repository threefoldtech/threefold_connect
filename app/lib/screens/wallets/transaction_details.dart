import 'package:flutter/material.dart';
import 'package:stellar_client/models/transaction.dart';
import 'package:threebotlogin/widgets/wallets/transaction_details.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final PaymentTransaction transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: TransactionDetails(
                transaction: transaction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
