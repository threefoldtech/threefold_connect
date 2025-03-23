import 'package:flutter/material.dart';
import 'package:threebotlogin/models/order_book.dart';
import 'package:threebotlogin/services/stellar_service.dart';

class OrderbookWidget extends StatefulWidget {
  const OrderbookWidget({super.key, required this.secret});

  final String secret;

  @override
  State<OrderbookWidget> createState() => _OrderbookWidgetState();
}

class _OrderbookWidgetState extends State<OrderbookWidget> {
  Stream<OrderBook>? _orderBookStream;

  @override
  void initState() {
    super.initState();
    _loadOrderBook();
  }

  void _loadOrderBook() async {
    _orderBookStream = await getOrderBook(widget.secret, 'USDC', 'TFT');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Amount (USDC)',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  Text('Price (TFT)',
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
                  Text('Amount (USDC)',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  Text('Price (TFT)',
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
                          Text(bid != null ? bid.amount.toString() : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer)),
                          Text(bid != null ? bid.price.toString() : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer)),
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
                          Text(ask != null ? ask.amount.toString() : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer)),
                          Text(ask != null ? ask.price.toString() : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer)),
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
