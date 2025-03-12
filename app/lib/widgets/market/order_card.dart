import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:intl/intl.dart';
import 'package:threebotlogin/widgets/market/order_details.dart';

class OrderCardWidget extends ConsumerStatefulWidget {
  final Offer offer;
  const OrderCardWidget({super.key, required this.offer});

  @override
  ConsumerState<OrderCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends ConsumerState<OrderCardWidget> {
  List<Widget> cardContent = [];

  String formatDateTime(String isoString) {
    DateTime dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double amount = double.parse(widget.offer.amount);
    final double pricePerTFT = double.parse(widget.offer.price);
    final double totalCost = amount * pricePerTFT;
    cardContent = [
      Row(
        children: [
          Text(
            'Price per TFT:',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            '${pricePerTFT.toStringAsFixed(2)} USDC',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
        ],
      ),
      Row(
        children: [
          Text(
            'Total Amount:',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            '${amount.toStringAsFixed(2)} TFT',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      Row(
        children: [
          Text(
            'Total Cost:',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            '- ${totalCost.toStringAsFixed(2)} USDC',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    ];

    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Theme.of(context).colorScheme.primary)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OrderDetailsWidget(
              offer: widget.offer,
            ),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                      child: Image.asset(
                    'assets/tf_chain.png',
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 20,
                    height: 20,
                  )),
                  SizedBox(
                      width: 30,
                      child: Image.asset(
                        'assets/usdc-icon.png',
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 20,
                        height: 20,
                      )),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Buy',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                  const Spacer(),
                  Text(
                    formatDateTime(widget.offer.lastModifiedTime),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...cardContent,
            ],
          ),
        ),
      ),
    );
  }
}
