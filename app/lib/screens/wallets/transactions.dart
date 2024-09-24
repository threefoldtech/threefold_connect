import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/widgets/wallets/transaction.dart';
import 'package:threebotlogin/widgets/wallets/vertical_divider.dart';
import 'package:stellar_flutter_sdk/src/responses/operations/payment_operation_response.dart';
import 'package:stellar_flutter_sdk/src/responses/operations/path_payment_strict_receive_operation_response.dart';

class WalletTransactionsWidget extends StatefulWidget {
  const WalletTransactionsWidget({super.key, required this.wallet});
  final Wallet wallet;

  @override
  State<WalletTransactionsWidget> createState() =>
      _WalletTransactionsWidgetState();
}

class _WalletTransactionsWidgetState extends State<WalletTransactionsWidget> {
  List<Transaction?> transactions = [];
  bool loading = true;

  _listTransactions() async {
    setState(() {
      loading = true;
    });
    final txs = await listTransactions(widget.wallet.stellarSecret);
    final transactionsList = txs.map((tx) {
      if (tx is PaymentOperationResponse) {
        return Transaction(
            hash: tx.transactionHash!,
            from: tx.from!.accountId,
            to: tx.to!.accountId,
            asset: tx.asset.toString(),
            amount: tx.amount!,
            type: TransactionType.Payment,
            status: tx.transactionSuccessful!,
            date: tx.createdAt!);
      } else if (tx is PathPaymentStrictReceiveOperationResponse) {
        return Transaction(
            hash: tx.transactionHash!,
            from: tx.from!,
            to: tx.to!,
            asset: tx.asset.toString(),
            type: TransactionType.Payment,
            status: tx.transactionSuccessful!,
            amount: tx.amount!,
            date: tx.createdAt!);
      }
      // TODO: handle creation transaction
    }).toList();
    transactions = transactionsList.where((tx) => tx != null).toList();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    _listTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: handle empty transactions
    Widget mainWidget;
    if (loading) {
      mainWidget = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(
            'Loading Transactions...',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else {
      mainWidget = ListView(
        children: [
          for (final tx in transactions)
            Column(
              children: [
                TransactionWidget(transaction: tx!),
                tx == transactions.last
                    ? const SizedBox()
                    : const CustomVerticalDivider()
              ],
            )
        ],
      );
    }
    return mainWidget;
  }
}
