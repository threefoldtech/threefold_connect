import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:threebotlogin/helpers/transaction_helpers.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:validators/validators.dart';

class BuyTFTWidget extends StatefulWidget {
  final Wallet wallet;
  const BuyTFTWidget({super.key, required this.wallet});

  @override
  State<BuyTFTWidget> createState() => _BuyTFTWidgetState();
}

class _BuyTFTWidgetState extends State<BuyTFTWidget> {
  final amountController = TextEditingController();

  final FocusNode textFieldFocusNode = FocusNode();
  String? amountError;
  // should be changed
  Decimal fee = Decimal.one.shift(-1);
  List percentages = [25, 50, 75, 100];

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    amountController.dispose();

    super.dispose();
  }

  bool _validateAmount() {
    final amount = amountController.text.trim();
    amountError = null;

    if (Decimal.parse(amount) <= fee) {
      amountError = 'Amount should be greater than $fee';
      return false;
    }
    if (amount.isEmpty) {
      amountError = "Amount can't be empty";
      return false;
    }
    if (!isFloat(amount)) {
      amountError = 'Amount should have numeric values only';
      return false;
    }
    final balance = roundAmount('500');

    if (balance - Decimal.parse(amount) - fee < Decimal.zero) {
      amountError = 'Balance is not enough';
      return false;
    }
    return true;
  }

  calculateAmount(int percentage) {
    // final amount = (Decimal.parse(chainType == ChainType.TFChain
    //             ? widget.wallet.tfchainBalance
    //             : widget.wallet.stellarBalance) -
    //         fee) *
    //     (Decimal.fromInt(percentage).shift(-2));
    // amountController.text = roundAmount(amount.toString()).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Buy')),
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
                              fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                            decimal: true),
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
                                'assets/tf_chain.png',
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'TFT',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
                              ),
                              const SizedBox(width: 5),
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
                          'Balance: ${widget.wallet.usdcBalance} USDC',
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
                              fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer
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
                            decimal: true),
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
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer)
                              ),
                              const SizedBox(width: 5),
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
                              fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer
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
                            decimal: true),
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
                              const SizedBox(width: 5),
                              Text(
                                'USDC',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
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
