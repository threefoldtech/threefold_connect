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
  List<Offer> orders = [];

  @override
  void initState() {
    orders = widget.offers;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant OrdersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.offers != oldWidget.offers) {
      setState(() {
        orders = widget.offers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<OrderCardWidget>? cards =
        _buildOffersCardsList(orders, widget.selectedWallet);
    return cards!.isNotEmpty
        ? SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: cards),
          )
        : Center(
            child: Text(
              'No Orders were found',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          );
  }
}

List<OrderCardWidget> _buildOffersCardsList(List<Offer> orders, Wallet wallet) {
  return orders.map((item) {
    return OrderCardWidget(
      offer: item,
      selectedWallet: wallet,
    );
  }).toList();
}
