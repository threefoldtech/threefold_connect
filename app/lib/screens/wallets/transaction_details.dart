import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/widgets/wallets/transaction_details.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
