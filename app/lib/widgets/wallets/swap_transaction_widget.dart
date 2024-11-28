import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class SwapTransactionWidget extends StatefulWidget {
  const SwapTransactionWidget({
    super.key,
    required this.bridgeOperation,
    required this.onTransactionChange,
    required this.disableDeposit,
  });

  final void Function(BridgeOperation bridgeOperation) onTransactionChange;
  final BridgeOperation bridgeOperation;
  final bool disableDeposit;
  final String withdrawIcon = 'assets/tf_chain.png';
  final String depositIcon = 'assets/stellar.png';

  @override
  _SwapTransactionWidgetState createState() => _SwapTransactionWidgetState();
}

class _SwapTransactionWidgetState extends State<SwapTransactionWidget> {
  late BridgeOperation currentOperation;

  @override
  void initState() {
    super.initState();
    currentOperation = widget.bridgeOperation;
  }

  void _swapTransactionType() {
    setState(() {
      // Swap between Withdraw and Deposit
      currentOperation = currentOperation == BridgeOperation.Withdraw
          ? BridgeOperation.Deposit
          : BridgeOperation.Withdraw;
    });
    widget.onTransactionChange(currentOperation);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final String leftIcon;
    final String leftChainLabel;
    final String rightIcon;
    final String rightChainLabel;
    if (currentOperation == BridgeOperation.Withdraw) {
      leftIcon = widget.withdrawIcon;
      leftChainLabel = 'TFChain';
      rightIcon = widget.depositIcon;
      rightChainLabel = 'Stellar';
    } else {
      leftIcon = widget.depositIcon;
      leftChainLabel = 'Stellar';
      rightIcon = widget.withdrawIcon;
      rightChainLabel = 'TFChain';
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 8),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Icon and Labels
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Image.asset(
                  leftIcon,
                  fit: BoxFit.contain,
                  color: colorScheme.onSurface,
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TFT',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        leftChainLabel,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurface,
                            ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Swap Icon
          SizedBox(
            width: 50,
            child: Center(
              child: GestureDetector(
                onTap: widget.disableDeposit ? null : _swapTransactionType,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: widget.disableDeposit
                      ? Theme.of(context).disabledColor
                      : colorScheme.primaryContainer,
                  child: Icon(
                    Icons.swap_horiz,
                    color: widget.disableDeposit
                        ? colorScheme.onSurface.withOpacity(0.5)
                        : colorScheme.onPrimaryContainer,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
          // Right Icon and Labels
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  rightIcon,
                  fit: BoxFit.contain,
                  color: colorScheme.onSurface,
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TFT',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        rightChainLabel,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurface,
                            ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
