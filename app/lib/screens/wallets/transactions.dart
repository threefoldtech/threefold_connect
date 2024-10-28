import 'package:flutter/material.dart';
import 'package:stellar_client/models/transaction.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/widgets/wallets/transaction.dart';
import 'package:threebotlogin/widgets/wallets/vertical_divider.dart';

class WalletTransactionsWidget extends StatefulWidget {
  const WalletTransactionsWidget({super.key, required this.wallet});
  final Wallet wallet;

  @override
  State<WalletTransactionsWidget> createState() =>
      _WalletTransactionsWidgetState();
}

class _WalletTransactionsWidgetState extends State<WalletTransactionsWidget> {
  List<PaymentTransaction?> transactions = [];
  bool loading = true;

  _listTransactions() async {
    setState(() {
      loading = true;
    });
    try {
      final txs = await listTransactions(widget.wallet.stellarSecret);
      final transactionsList = txs.map((tx) {
        if (tx is PaymentTransaction) {
          return tx;
        }
      }).toList();
      transactions = transactionsList.where((tx) => tx != null).toList();
    } catch (e) {
      print('Failed to load transactions due to $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to load transaction',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.wallet.stellarBalance != '-1') {
      _listTransactions();
    } else {
      setState(() {
        loading = false;
        transactions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else if (transactions.isEmpty) {
      mainWidget = Center(
        child: Text(
          'No transactions yet.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      );
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
