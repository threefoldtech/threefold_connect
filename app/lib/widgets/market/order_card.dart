import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/models/offer.dart';

class OrderCardWidget extends ConsumerStatefulWidget {
  final Offer offer;
  const OrderCardWidget({super.key, required this.offer});

  @override
  ConsumerState<OrderCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends ConsumerState<OrderCardWidget> {
  List<Widget> cardContent = [];

  @override
  Widget build(BuildContext context) {
    cardContent = [
      Row(
        children: [
          Text(
            'Price per TFT: ${double.parse(widget.offer.price).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            '+ ${widget.offer.amount} TFT',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
        ],
      ),
      Row(
        children: [
          SizedBox(
              width: 35,
              child: Image.asset(
                'assets/tf_chain.png',
                color: Theme.of(context).colorScheme.onSurface,
                width: 20,
                height: 20,
              )),
          Text(
            'TFChain',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
          const Spacer(),
          // Text(
          //   '${formatAmount(widget.wallet.tfchainBalance)} TFT',
          //   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          //         color: Theme.of(context).colorScheme.onSecondaryContainer,
          //       ),
          // ),
        ],
      )
    ];

    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Theme.of(context).colorScheme.primary)),
      child: InkWell(
        onTap: () {
          // if (widget.wallet.type == WalletType.NATIVE &&
          //     widget.wallet.stellarBalance == '-1') {
          //   return;
          // }
          // Navigator.of(context).push(MaterialPageRoute(
          //   builder: (context) => WalletDetailsScreen(
          //     wallet: widget.wallet,
          //   ),
          // ));
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
                    widget.offer.lastModifiedTime,
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
