import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class SwapTransactionWidget extends StatefulWidget {
  const SwapTransactionWidget({
    super.key,
    required this.transactionType,
    required this.onTransactionChange,
    required this.hideDeposit,
  });

  final void Function(TransactionType transactionType) onTransactionChange;
  final TransactionType transactionType;
  final bool hideDeposit;
  final String withdrawIcon = 'assets/tf_chain.png';
  final String depositIcon = 'assets/stellar.png';

  @override
  _SwapTransactionWidgetState createState() => _SwapTransactionWidgetState();
}

class _SwapTransactionWidgetState extends State<SwapTransactionWidget> {
  late TransactionType currentTransactionType;

  @override
  void initState() {
    super.initState();
    currentTransactionType = widget.transactionType;
  }

  void _swapTransactionType() {
    setState(() {
      // Swap between Withdraw and Deposit
      currentTransactionType =
          currentTransactionType == TransactionType.Withdraw
              ? TransactionType.Deposit
              : TransactionType.Withdraw;
    });
    widget.onTransactionChange(currentTransactionType);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Get the icons based on the current transaction type
    final String leftIcon = currentTransactionType == TransactionType.Withdraw
        ? widget.withdrawIcon
        : widget.depositIcon;
    final String leftChainLabel =
        currentTransactionType == TransactionType.Withdraw
            ? 'TFChain'
            : 'Stellar';
    final String rightIcon = currentTransactionType == TransactionType.Withdraw
        ? widget.depositIcon
        : widget.withdrawIcon;
    final String rightChainLabel =
        currentTransactionType == TransactionType.Withdraw
            ? 'Stellar'
            : 'TFChain';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Icon and Labels
          SizedBox(
            width: width / 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primaryContainer,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      leftIcon,
                      fit: BoxFit.contain,
                      width: 35,
                      height: 35,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        leftChainLabel,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'TFT',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
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
                onTap: widget.hideDeposit ? null : _swapTransactionType,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: widget.hideDeposit
                      ? Theme.of(context).disabledColor
                      : colorScheme.primaryContainer,
                  child: Icon(
                    Icons.swap_horiz,
                    color: widget.hideDeposit
                        ? colorScheme.onSurface
                        : colorScheme.onPrimaryContainer,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
          // Right Icon and Labels
          SizedBox(
            width: width / 3,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rightChainLabel,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'TFT',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primaryContainer,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      rightIcon,
                      fit: BoxFit.contain,
                      width: 35,
                      height: 35,
                    ),
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
