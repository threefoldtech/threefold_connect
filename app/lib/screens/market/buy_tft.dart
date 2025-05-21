import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:stellar_client/models/exceptions.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/helpers/transaction_helpers.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/orders_notifier.dart';
import 'package:threebotlogin/screens/market/order.dart';
import 'package:threebotlogin/services/stellar_service.dart' as Stellar;
import 'package:threebotlogin/widgets/custom_dialog.dart';

class BuyTFTWidget extends StatefulWidget {
  final Wallet wallet;
  final Offer? offer;
  final bool edit;
  const BuyTFTWidget(
      {super.key, required this.wallet, this.offer, required this.edit});

  @override
  State<BuyTFTWidget> createState() => _BuyTFTWidgetState();
}

class _BuyTFTWidgetState extends State<BuyTFTWidget> {
  late TextEditingController amountController;
  late TextEditingController priceController;
  final totalAmountController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();
  String? amountError;
  String? priceError;
  bool loading = false;
  bool loadingPrice = true;
  double? currentMarketPrice;
  List percentages = [25, 50, 75, 100];
  bool loadingBalance = true;
  String? availableUSDC;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
        text: widget.edit ? widget.offer?.amount.toString() ?? '' : '');
    priceController = TextEditingController(
        text: widget.edit ? widget.offer?.price.toString() ?? '' : '');
    amountController.addListener(_calculateTotal);
    priceController.addListener(_calculateTotal);
    if (widget.edit) _calculateTotal();
    if (!widget.edit) _fetchCurrentMarketPrice();
    _getAvailableUSDC();
  }

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    amountController.dispose();
    priceController.dispose();
    totalAmountController.dispose();
    amountError = null;
    priceError = null;
    amountController.removeListener(_calculateTotal);
    priceController.removeListener(_calculateTotal);
    super.dispose();
  }

  _getAvailableUSDC() async {
    setState(() {
      loadingBalance = true;
    });

    try {
      final available = await Stellar.getAvailableUSDCBalance(
          widget.wallet.stellarSecret, widget.offer);

      if (mounted) {
        setState(() {
          availableUSDC = available;
          loadingBalance = false;
        });
      }
    } catch (e) {
      logger.e('Error fetching USDC balance: $e');
      if (mounted) {
        setState(() {
          availableUSDC = '0';
          loadingBalance = false;
        });
      }
    }
  }

  Future<void> _fetchCurrentMarketPrice() async {
    try {
      setState(() {
        loadingPrice = true;
      });

      final marketData = await Stellar.fetchTftMarketData();
      if (marketData != null && marketData.lastUsdPrice > 0) {
        setState(() {
          currentMarketPrice = 1 / marketData.lastUsdPrice;
          loadingPrice = false;

          if (!widget.edit && priceController.text.isEmpty) {
            priceController.text = currentMarketPrice!.toStringAsFixed(7);
            _calculateTotal();
          }
        });
      } else {
        setState(() {
          loadingPrice = false;
          priceController.text = '';
        });
      }
    } catch (e) {
      logger.e('Error fetching market price: $e');
      setState(() {
        loadingPrice = false;
        priceController.text = '';
      });
    }
  }

  bool _validateAmount() {
    final amount = amountController.text.trim();
    amountError = null;

    if (loadingBalance) {
      setState(() {
        amountError = 'Please wait for balance to load';
      });
      return false;
    }

    if (amount.isEmpty) {
      setState(() {
        amountError = "Amount can't be empty";
      });
      return false;
    }
    final balance = roundAmount(availableUSDC ?? '0');

    if (balance - Decimal.parse(amount) <= Decimal.zero) {
      setState(() {
        amountError = 'Balance is not enough';
      });
      return false;
    }

    if (Decimal.parse(amount) > Decimal.parse(availableUSDC ?? '0')) {
      setState(() {
        amountError = 'Not enough balance';
      });
      return false;
    }
    return true;
  }

  bool _validatePrice() {
    final price = priceController.text.trim();
    priceError = null;

    if (price.isEmpty) {
      setState(() {
        priceError = "Price can't be empty";
      });
      return false;
    }
    if (Decimal.parse(price) <= Decimal.zero) {
      setState(() {
        priceError = 'Price should be positive';
      });
      return false;
    }

    return true;
  }

  calculateAmount(int percentage) {
    final amount = Decimal.parse(availableUSDC ?? '0') *
        (Decimal.fromInt(percentage).shift(-2));
    amountController.text = roundAmount(amount.toString()).toString();
    _calculateTotal();
  }

  void _calculateTotal() {
    final amountText = amountController.text.trim();
    final priceText = priceController.text.trim();

    if (amountText.isNotEmpty && priceText.isNotEmpty) {
      try {
        final amount = Decimal.parse(amountText);
        final price = Decimal.parse(priceText);
        final total = amount * price;
        totalAmountController.text = roundAmount(total.toString()).toString();
      } catch (e) {
        totalAmountController.text = '';
      }
    } else {
      totalAmountController.text = '';
    }
  }

  bool _checkForChanges() {
    final boolean = (amountController.text != widget.offer!.amount) ||
        (priceController.text != widget.offer!.price);
    return boolean;
  }

  _createOrder() async {
    setState(() {
      loading = true;
    });
    try {
      final success = await Stellar.createOrder(widget.wallet.stellarSecret,
          'USDC', 'TFT', amountController.text, priceController.text);
      if (success) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomDialog(
              image: Icons.check,
              title: 'Success!',
              description: 'Your order was created successfully.',
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderWidget(
                            selectedWallet: widget.wallet,
                          ),
                        ));
                    OrderNotifier.emitUpdate();
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
              title: 'Failed!',
              type: DialogType.Error,
              description: 'Failed to create your order.',
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ]),
        );
      }
    } on StellarBalanceException catch (e) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: 'Balance Error',
            type: DialogType.Error,
            description: e.isLowReserve
                ? 'You need to fund your account with some XLMs to create your order'
                : 'Error creating your order: ${e.toString()}',
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ]),
      );
      return;
    } catch (e) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: 'Error',
            type: DialogType.Error,
            description: 'Error creating your order: ${e.toString()}',
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ]),
      );
      return;
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  _updateOrder() async {
    final bool shouldCancel = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext customContext) => CustomDialog(
            type: DialogType.Warning,
            image: Icons.warning,
            title: 'Update Order',
            description: 'Are you sure you want to update this order?',
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
      final success = await Stellar.updateOrder(widget.wallet.stellarSecret,
          amountController.text, priceController.text, widget.offer!.id);
      if (success) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomDialog(
              image: Icons.check,
              title: 'Success!',
              description: 'Your order was updated successfully.',
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    OrderNotifier.emitUpdate();
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
              title: 'Failed!',
              type: DialogType.Error,
              description: 'Failed to update your order.',
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ]),
        );
      }
    } on StellarBalanceException catch (e) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: 'Balance Error',
            type: DialogType.Error,
            description: e.isLowReserve
                ? 'You need to fund your account with some XLMs to update your order'
                : 'Error updating your order: ${e.toString()}',
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ]),
      );
      return;
    } catch (e) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: 'Error',
            type: DialogType.Error,
            description: 'Error updating your order: ${e.toString()}',
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ]),
      );
      return;
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: widget.edit ? const Text('Edit Order') : const Text('Buy')),
        body: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    ListTile(
                      title: TextField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        focusNode: textFieldFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: false),
                        controller: amountController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          errorText: amountError,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/usdc-icon.png',
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'USDC',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: loadingBalance
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Loading balance...',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              )
                            : Text(
                                'Available: $availableUSDC USDC',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: percentages
                            .map(
                              (percentage) => OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)))),
                                onPressed: loadingBalance
                                    ? null
                                    : () => calculateAmount(percentage),
                                child: Text('$percentage%'),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 100),
                    ListTile(
                      title: TextField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: false),
                        controller: priceController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          errorText: priceError,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/tf_chain.png',
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text('TFT',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer)),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      title: TextField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        controller: totalAmountController,
                        readOnly: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Total amount',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/tf_chain.png',
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'TFT',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (amountError != null && priceError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        child: Text(
                          'You are selling ${amountController.text} USDC for ${totalAmountController.text} TFT. ',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading || loadingBalance
                              ? null
                              : () async {
                                  if (_validateAmount() && _validatePrice()) {
                                    if (widget.edit && _checkForChanges()) {
                                      _updateOrder();
                                    } else {
                                      _createOrder();
                                    }
                                  } else {
                                    setState(() {});
                                  }
                                },
                          style: ElevatedButton.styleFrom(),
                          child: loading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 3),
                                    ),
                                  ],
                                )
                              : Text(
                                  widget.edit ? 'Edit order' : 'Buy TFT',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                          ),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        }));
  }
}
