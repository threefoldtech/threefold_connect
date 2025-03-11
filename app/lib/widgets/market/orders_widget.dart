import 'package:flutter/material.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:threebotlogin/widgets/market/order_card.dart';

class OrdersWidget extends StatefulWidget {
  final List<Offer> offers;
  final bool active;

  const OrdersWidget({super.key, required this.offers, this.active = false});

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
  Widget build(BuildContext context) {
  final List<OrderCardWidget>? cards = _buildOffersCardsList(orders);
    return SingleChildScrollView(
      child: Column(
                          mainAxisSize: MainAxisSize.min, children: cards!),
    );
  }
}

List<OrderCardWidget> _buildOffersCardsList(List<Offer> orders) {
  return orders.map((item) {
    return OrderCardWidget(
      offer: item,
    );
  }).toList();
}
