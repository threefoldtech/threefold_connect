import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/helpers/transaction_helpers.dart';
import 'package:threebotlogin/models/order_book.dart';
import 'package:threebotlogin/services/stellar_service.dart';

class OrderbookWidget extends StatefulWidget {
  const OrderbookWidget({super.key});

  @override
  State<OrderbookWidget> createState() => _OrderbookWidgetState();
}

class _OrderbookWidgetState extends State<OrderbookWidget> {
  Stream<OrderBook>? _orderBookStream;
  bool _isLoading = true;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    _loadOrderBook();
  }

  void _loadOrderBook() async {
    _setLoadingState();

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _handleFailure(
          'No internet connection. Please check your network.',
        );
        return;
      }

      _orderBookStream = await listOrderBook(
        AssetTypeCreditAlphaNum4(tftAssetCode, tftAssetIssuer),
        AssetTypeCreditAlphaNum4(usdcAssetCode, usdcAssetIssuer),
      ).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw TimeoutException('Loading orderbook timed out');
        },
      );

      _orderBookStream!.first.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('No data received from orderbook stream');
        },
      );
      setState(() {
        _isLoading = false;
        failed = false;
      });
    } on TimeoutException catch (e) {
      _handleFailure(
        'Loading orderbook timed out. Please check your network',
        error: e,
      );
    } catch (e) {
      _handleFailure(
        'Failed to load orderbook. Please try again.',
        error: e,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setLoadingState() {
    setState(() {
      _isLoading = true;
      failed = false;
    });
  }

  void _handleFailure(String userMessage, {Object? error}) {
    if (error != null) {
      logger.e('Load orderbook failed', error: error);
    }

    if (mounted) {
      final errorSnackbar = SnackBar(
        content: Text(
          userMessage,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.errorContainer),
        ),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(errorSnackbar);
    }

    setState(() {
      _isLoading = false;
      failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading orderbook...'),
          ],
        ),
      );
    }

    if (failed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: _loadOrderBook,
            ),
          ],
        ),
      );
    }
    return _orderBookStream == null
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<OrderBook>(
            stream: _orderBookStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final orderBook = snapshot.data!;
              return _buildOrderBookTable(orderBook);
            },
          );
  }

  Widget _buildOrderBookTable(OrderBook orderBook) {
    final int maxRows = orderBook.bids.length > orderBook.asks.length
        ? orderBook.bids.length
        : orderBook.asks.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Buy Offers',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Sell Offers',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        ),
        Divider(
            thickness: 1,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Amount (TFT)',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  Text('Price (USDC)',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ),
            Container(
                width: 1,
                height: 30,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Amount (TFT)',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  Text('Price (USDC)',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Expanded(
          child: ListView.builder(
            itemCount: maxRows,
            itemBuilder: (context, index) {
              final bid =
                  index < orderBook.bids.length ? orderBook.bids[index] : null;
              final ask =
                  index < orderBook.asks.length ? orderBook.asks[index] : null;

              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                              bid != null
                                  ? (double.tryParse(bid.price) != null &&
                                          double.parse(bid.price) > 0)
                                      ? formatAmountDisplay((double.parse(bid.amount) /
                                              double.parse(bid.price))
                                          .toString())
                                      : ''
                                  : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                          Text(
                              bid != null
                                  ? (double.tryParse(bid.price) != null &&
                                          double.parse(bid.price) > 0)
                                      ? formatAmountDisplay(bid.price.toString())
                                      : ''
                                  : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 30,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(ask != null ? formatAmountDisplay(ask.amount.toString()) : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                          Text(ask != null ? formatAmountDisplay(ask.price.toString()) : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
