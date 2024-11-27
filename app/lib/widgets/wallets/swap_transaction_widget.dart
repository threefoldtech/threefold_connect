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
    final colorScheme = Theme.of(context).colorScheme;

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

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 8),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
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
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    leftIcon,
                    fit: BoxFit.contain,
                    width: 30,
                    height: 30,
                  ),
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
                onTap: widget.hideDeposit ? null : _swapTransactionType,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: widget.hideDeposit
                      ? Theme.of(context).disabledColor.withOpacity(0.7)
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
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    rightIcon,
                    fit: BoxFit.contain,
                    width: 30,
                    height: 30,
                  ),
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
