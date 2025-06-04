import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/offer.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:threebotlogin/models/wallet.dart' as Wallet;
import 'package:threebotlogin/screens/market/order_details.dart';

class OrderCardWidget extends ConsumerStatefulWidget {
  final Offer offer;
  final Wallet.Wallet selectedWallet;
  final bool active;
  const OrderCardWidget(
      {super.key,
      required this.offer,
      required this.selectedWallet,
      required this.active});

  @override
  ConsumerState<OrderCardWidget> createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends ConsumerState<OrderCardWidget> {
  String formatDateTime(String isoString) {
    try {
      DateTime dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (e) {
      logger.e('Error formatting date: $e');
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final double amount = double.parse(widget.offer.amount);
      double pricePerTFT;
      try {
        pricePerTFT = double.parse(widget.offer.price) > 0
            ? 1 / double.parse(widget.offer.price)
            : 0;
      } catch (e) {
        logger.e('Error parsing price: ${widget.offer.price}, error: $e');
        pricePerTFT = 0;
      }
      final double totalCost = pricePerTFT > 0 ? amount / pricePerTFT : 0;

      List<Widget> cardContent = [];

      cardContent = [
        _buildInfoRow(context, 'Amount:', '- ${amount.toStringAsFixed(2)} USDC',
            textColor: Theme.of(context).colorScheme.error),
        _buildInfoRow(
            context, 'Price per TFT:', '${pricePerTFT.toStringAsFixed(4)} USDC',
            isHighlighted: true),
        _buildInfoRow(context, 'Total Received:',
            '+ ${(totalCost).toStringAsFixed(4)} TFT',
            textColor: Theme.of(context).colorScheme.primary),
      ];

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OrderDetailsWidget(
                active: widget.active,
                offer: widget.offer,
                selectedWallet: widget.selectedWallet,
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
                      width: 24,
                      height: 24,
                      child: Image.asset(
                        'assets/usdc-icon.png',
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Image.asset(
                        'assets/tf_chain.png',
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Buy',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatDateTime(widget.offer.lastModifiedTime),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ...cardContent,
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      logger.e('Error building OrderCardWidget: $e');
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error displaying order: ${e.toString()}',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ),
      );
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlighted = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: isHighlighted
                ? Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: textColor,
                    ),
          ),
        ],
      ),
    );
  }
}
