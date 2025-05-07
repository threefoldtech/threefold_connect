import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:intl/intl.dart';
import 'package:threebotlogin/models/wallet.dart' as Wallet;
import 'package:threebotlogin/widgets/market/order_details.dart';

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
        pricePerTFT = double.parse(widget.offer.price);
      } catch (e) {
        logger.e('Error parsing price: ${widget.offer.price}, error: $e');
        pricePerTFT = 0;
      }
      final double totalCost = amount * pricePerTFT;

      final bool isBuyOrder = widget.offer.sellingAsset == 'USDC' &&
          widget.offer.buyingAsset == 'TFT';
      final bool isSellOrder = widget.offer.sellingAsset == 'TFT' &&
          widget.offer.buyingAsset == 'USDC';

      final String orderTypeText = isBuyOrder ? 'Buy' : 'Sell';

      List<Widget> cardContent = [];

      if (isBuyOrder) {
        cardContent = [
          _buildInfoRow(
              context, 'Amount:', '- ${amount.toStringAsFixed(2)} USDC'),
          _buildInfoRow(context, 'Price per TFT:',
              '${pricePerTFT.toStringAsFixed(4)} USDC',
              isHighlighted: true),
          _buildInfoRow(context, 'Total Received:',
              '+ ${(amount / pricePerTFT).toStringAsFixed(4)} TFT'),
        ];
      } else if (isSellOrder) {
        cardContent = [
          _buildInfoRow(
              context, 'Amount:', '- ${amount.toStringAsFixed(2)} TFT'),
          _buildInfoRow(context, 'Price per TFT:',
              '${pricePerTFT.toStringAsFixed(4)} USDC',
              isHighlighted: true),
          _buildInfoRow(context, 'Total Received:',
              '+ ${totalCost.toStringAsFixed(4)} USDC'),
        ];
      } else {
        cardContent = [
          Text(
            'Unknown order type: ${widget.offer.sellingAsset} -> ${widget.offer.buyingAsset}',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ];
      }

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
                        isBuyOrder
                            ? 'assets/usdc-icon.png'
                            : 'assets/tf_chain.png',
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
                        isBuyOrder
                            ? 'assets/tf_chain.png'
                            : 'assets/usdc-icon.png',
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isBuyOrder
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        orderTypeText,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: isBuyOrder
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
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

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isHighlighted = false}) {
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
        ],
      ),
    );
  }
}
