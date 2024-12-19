import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class SwapTransactionWidget extends StatefulWidget {
  const SwapTransactionWidget({
    super.key,
    required this.bridgeOperation,
    required this.onTransactionChange,
    required this.disableDeposit,
    required this.depositChain,
  });

  final void Function(BridgeOperation bridgeOperation) onTransactionChange;
  final BridgeOperation bridgeOperation;
  final bool disableDeposit;
  final DepositChain depositChain;

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
    final String leftChainLabel;
    final String rightChainLabel;

    if (currentOperation == BridgeOperation.Withdraw) {
      leftChainLabel = 'TF Chain';
      rightChainLabel = widget.depositChain.name;
    } else {
      leftChainLabel = widget.depositChain.name;
      rightChainLabel = 'TF Chain';
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
          _buildChainInfo(context, leftChainLabel),
          _buildSwapButton(context),
          _buildChainInfo(context, rightChainLabel, isLeftSide: false),
        ],
      ),
    );
  }

  Widget _buildChainInfo(
    BuildContext context,
    String chainLabel, {
    bool isLeftSide = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Flexible(
      flex: 1,
      child: Row(
        mainAxisAlignment:
            isLeftSide ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          const SizedBox(width: 5),
          Flexible(
            child: _ChainLabels(
              chainLabel: chainLabel,
              colorScheme: colorScheme,
              textTheme: Theme.of(context).textTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
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
    );
  }
}

class _ChainLabels extends StatefulWidget {
  final String chainLabel;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final List<String> chains = ['TF Chain', 'Stellar', 'Solana'];

  _ChainLabels({
    required this.chainLabel,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  _ChainLabelsState createState() => _ChainLabelsState();
}

class _ChainLabelsState extends State<_ChainLabels> {
  late String selectedChain;

  @override
  void initState() {
    super.initState();
    selectedChain = widget.chainLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedChain,
            selectedItemBuilder: (BuildContext context) {
              return widget.chains.map((String value) {
                return Row(
                  children: [
                    Image.asset(
                      _getChainIcon(value),
                      fit: BoxFit.contain,
                      color: widget.colorScheme.onSurface,
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TFT',
                          style: widget.textTheme.bodySmall!.copyWith(
                            color: widget.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: widget.textTheme.bodySmall!.copyWith(
                            color: widget.colorScheme.onSurface,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ],
                );
              }).toList();
            },
            items: widget.chains.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Image.asset(
                      _getChainIcon(value),
                      fit: BoxFit.contain,
                      color: widget.colorScheme.onSurface,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      value,
                      style: widget.textTheme.bodySmall!.copyWith(
                        color: widget.colorScheme.onSurface,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedChain = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  String _getChainIcon(String chain) {
    switch (chain) {
      case 'Stellar':
        return 'assets/stellar.png';
      case 'Solana':
        return 'assets/solana.png';
      case 'TF Chain':
      default:
        return 'assets/tf_chain.png';
    }
  }
}
