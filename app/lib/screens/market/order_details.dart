import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart' as Stellar;
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/screens/market/buy_tft.dart';
import 'package:threebotlogin/providers/orders_notifier.dart';

class OrderDetailsWidget extends StatefulWidget {
  final Wallet selectedWallet;
  final Offer offer;
  final bool active;

  const OrderDetailsWidget(
      {super.key,
      required this.selectedWallet,
      required this.offer,
      required this.active});

  @override
  _OrderDetailsWidgetState createState() => _OrderDetailsWidgetState();
}

class _OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  _cancelOrder() async {
    final bool shouldCancel = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext customContext) => CustomDialog(
            type: DialogType.Warning,
            image: Icons.warning,
            title: 'Cancel Order',
            description: 'Are you sure you want to cancel this order?',
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(customContext, false);
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.pop(customContext, true);
                },
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldCancel) return;
    setState(() {
      loading = true;
    });
    try {
      final success = await Stellar.cancelOrder(
          widget.selectedWallet.stellarSecret, widget.offer.id);
      OrderNotifier.emitUpdate();
      if (success) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomDialog(
              image: Icons.check,
              title: 'Success!',
              description: 'Your order has been cancelled successfully.',
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ]),
        );
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomDialog(
              image: Icons.error,
              title: 'Failed',
              description: 'Failed to cancel your order.',
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ]),
        );
      }
    } catch (e) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: 'Error',
            description: e.toString().contains('low reserve')
                ? 'You need to fund your account with some XLMs to cancel an order'
                : 'Error cancelling your order',
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ]),
      );
      logger.e('Error cancelling order due to $e');
      return;
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double amount = double.parse(widget.offer.amount);
    final double pricePerTFT = double.parse(widget.offer.price);
    final double pricePerUSDC = pricePerTFT > 0 ? 1 / pricePerTFT : 0;
    final double totalCost = amount * pricePerTFT;
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/usdc-icon.png',
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/tf_chain.png',
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'USDC / TFT',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Buy ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        widget.active
                            ? Text(
                                '(Active)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              )
                            : Text(
                                '(Inactive)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            customDivider(context: context),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buy Amount',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '${totalCost.toStringAsFixed(2)} TFT',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Price Per TFT',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '${pricePerUSDC.toString()} USDC',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Price Per USDC',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '${pricePerTFT.toStringAsFixed(2)} TFT',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Sell Amount',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '${amount.toStringAsFixed(2)} USDC',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            customDivider(context: context),
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Updated',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          Text(
                            widget.offer.lastModifiedTime,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          )
                        ]))),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: widget.active
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BuyTFTWidget(
                                  wallet: widget.selectedWallet,
                                  offer: widget.offer,
                                  edit: true,
                                )));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Text(
                        'Edit Order',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        _cancelOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ))
                          : Text(
                              'Cancel Order',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget customDivider({
    required BuildContext context,
  }) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: const Divider(
          thickness: 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }
}
