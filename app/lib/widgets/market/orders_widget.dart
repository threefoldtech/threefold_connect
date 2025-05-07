import 'package:flutter/material.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/widgets/market/order_card.dart';

class OrdersWidget extends StatefulWidget {
  final List<Offer> offers;
  final bool active;
  final Wallet selectedWallet;

  const OrdersWidget(
      {super.key,
      required this.offers,
      this.active = false,
      required this.selectedWallet});

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends State<OrdersWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(OrdersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              widget.active ? 'No active orders' : 'No trade history',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (!widget.active) const SizedBox(height: 8),
            if (!widget.active)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Your completed trades will appear here',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.7),
                      ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: widget.offers.map((offer) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OrderCardWidget(
            key: ValueKey(offer.id),
            offer: offer,
            selectedWallet: widget.selectedWallet,
            active: widget.active,
          ),
        );
      }).toList(),
    );
  }
}
