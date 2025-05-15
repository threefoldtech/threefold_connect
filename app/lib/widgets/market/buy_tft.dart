import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/helpers/transaction_helpers.dart';
import 'package:threebotlogin/models/offer.dart';
import 'package:threebotlogin/models/wallet.dart';
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
    _fetchCurrentMarketPrice();
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
        });
      }
    } catch (e) {
      logger.e('Error fetching market price: $e');
      setState(() {
        loadingPrice = false;
      });
    }
  }

  bool _validateAmount() {
    final amount = amountController.text.trim();
    amountError = null;

    if (amount.isEmpty) {
      setState(() {
        amountError = "Amount can't be empty";
      });
      return false;
    }
    final balance = roundAmount(widget.wallet.stellarBalances['USDC']!);

    if (balance - Decimal.parse(amount) <= Decimal.zero) {
      setState(() {
        amountError = 'Balance is not enough';
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
    final amount =
        Decimal.parse(widget.wallet.stellarBalances['USDC']!!) * (Decimal.fromInt(percentage).shift(-2));
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
    } catch (e) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: 'Error',
            description: 'Error creating your order',
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
    } catch (e) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: 'Error',
            description: 'Error updating your order',
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'Amount',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                      ),
                    ),
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
                          hintText: 'Enter amount',
                          errorText: amountError,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              )),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
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
                        child: Text(
                          'Available: ${widget.wallet.stellarBalances['USDC']!} USDC',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
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
                                onPressed: () => calculateAmount(percentage),
                                child: Text('$percentage%'),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'Price',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer),
                      ),
                    ),
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
                          hintText: 'Enter price',
                          errorText: priceError,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              )),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer),
                      ),
                    ),
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
                          hintText: 'Total amount',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              )),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
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
                          onPressed: () async {
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
                    if (widget.edit)
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
