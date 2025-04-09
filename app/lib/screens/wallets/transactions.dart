import 'package:flutter/material.dart';
import 'package:stellar_client/models/transaction.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/widgets/wallets/transaction.dart';
import 'package:threebotlogin/widgets/wallets/vertical_divider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class WalletTransactionsWidget extends StatefulWidget {
  const WalletTransactionsWidget({super.key, required this.wallet});
  final Wallet wallet;

  @override
  State<WalletTransactionsWidget> createState() =>
      _WalletTransactionsWidgetState();
}

class _WalletTransactionsWidgetState extends State<WalletTransactionsWidget> {
  final _pageSize = 10;
  final PagingController<String?, ITransaction> _pagingController =
      PagingController(firstPageKey: null);

  void _listTransactions(String? pagingToken) async {
    try {
      final txStream = listTransactions(
        widget.wallet.stellarSecret,
        pagingToken,
        _pageSize,
      );

      final txs = await txStream.take(_pageSize).toList();

      if (txs.isEmpty) {
        _pagingController.appendLastPage([]);
        return;
      }

      final lastTx = txs.last as PaymentTransaction;
      final adjustedPagingToken =
          (BigInt.parse(lastTx.pagingToken) - BigInt.one).toString();

      if (txs.length < _pageSize) {
        _pagingController.appendLastPage(txs);
      } else {
        _pagingController.appendPage(txs, adjustedPagingToken);
      }
    } catch (e) {
      logger.e('Failed to load transactions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load transactions',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.errorContainer,
                  ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      _pagingController.error = e;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.wallet.stellarBalance != '-1') {
      _pagingController.addPageRequestListener(_listTransactions);
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wallet.stellarBalance == '-1') {
      return Center(
        child: Text(
          'No transactions yet.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      );
    }

    return PagedListView<String?, ITransaction>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<ITransaction>(
        itemBuilder: (context, item, index) => Column(
          children: [
            TransactionWidget(transaction: item as PaymentTransaction),
            if (index < _pagingController.itemList!.length - 1)
              const CustomVerticalDivider()
            else
              const SizedBox(height: 5),
          ],
        ),
        firstPageProgressIndicatorBuilder: (context) => Center(
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
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => Center(
          child: Text(
            'No transactions yet.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
