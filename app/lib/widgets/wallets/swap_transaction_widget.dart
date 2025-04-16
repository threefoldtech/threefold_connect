import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

enum Chains { TFChain, Stellar, Solana }

class SwapTransactionWidget extends StatefulWidget {
  const SwapTransactionWidget({
    super.key,
    required this.bridgeOperation,
    required this.onTransactionChange,
    required this.disableDeposit,
    required this.updateIsSolana,
  });

  final void Function(BridgeOperation bridgeOperation) onTransactionChange;
  final BridgeOperation bridgeOperation;
  final bool disableDeposit;
  final Function(bool) updateIsSolana;

  @override
  _SwapTransactionWidgetState createState() => _SwapTransactionWidgetState();
}

class _SwapTransactionWidgetState extends State<SwapTransactionWidget> {
  late BridgeOperation currentOperation;
  late String leftSelectedChain;
  late String rightSelectedChain;

  @override
  void initState() {
    super.initState();
    currentOperation = widget.bridgeOperation;
    _initializeChains();
  }

  void _initializeChains() {
    if (currentOperation == BridgeOperation.Withdraw) {
      leftSelectedChain = Chains.TFChain.name;
      rightSelectedChain = Chains.Stellar.name;
    } else {
      leftSelectedChain = Chains.Stellar.name;
      rightSelectedChain = Chains.TFChain.name;
    }
  }

  void _swapTransactionType() {
    setState(() {
      currentOperation = currentOperation == BridgeOperation.Withdraw
          ? BridgeOperation.Deposit
          : BridgeOperation.Withdraw;
      // Swap chains
      final temp = leftSelectedChain;
      leftSelectedChain = rightSelectedChain;
      rightSelectedChain = temp;
    });
    widget.onTransactionChange(currentOperation);
  }

  void _handleLeftChainChange(String newChain) {
    setState(() {
      leftSelectedChain = newChain;
      if (newChain == Chains.TFChain.name) {
        currentOperation = BridgeOperation.Withdraw;
        _handleRightChainChange(Chains.Stellar.name);
      } else {
        currentOperation = BridgeOperation.Deposit;
      }
    });
    widget.onTransactionChange(currentOperation);
  }

  void _handleRightChainChange(String newChain) {
    setState(() => rightSelectedChain = newChain);
    widget.updateIsSolana(newChain == Chains.Solana.name);
    widget.onTransactionChange(currentOperation);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final disableSwap = rightSelectedChain == Chains.Solana.name ||
        widget.disableDeposit && rightSelectedChain == Chains.Stellar.name;

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
          _buildChainInfo(
            context,
            selectedChain: leftSelectedChain,
            excludeChains: [rightSelectedChain],
            onChainChanged: _handleLeftChainChange,
            disabledChains: rightSelectedChain == Chains.Solana.name
                ? [Chains.TFChain.name, Chains.Solana.name]
                : [Chains.Solana.name],
          ),
          _buildSwapButton(context, disableSwap),
          _buildChainInfo(
            context,
            selectedChain: rightSelectedChain,
            excludeChains: [leftSelectedChain],
            disabledChains: leftSelectedChain == Chains.TFChain.name
                ? [Chains.Solana.name]
                : [],
            onChainChanged: _handleRightChainChange,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildChainInfo(
    BuildContext context, {
    required String selectedChain,
    required List<String> excludeChains,
    required ValueChanged<String> onChainChanged,
    bool isLeft = true,
    List<String> disabledChains = const [],
  }) {
    return Flexible(
      flex: 1,
      child: Row(
        mainAxisAlignment:
            isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          const SizedBox(width: 5),
          Flexible(
            child: ChainDropdown(
              selectedChain: selectedChain,
              excludeChains: excludeChains,
              onChanged: onChainChanged,
              colorScheme: Theme.of(context).colorScheme,
              textTheme: Theme.of(context).textTheme,
              disabledChains: disabledChains,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton(BuildContext context, bool disableSwap) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 50,
      child: Center(
        child: GestureDetector(
          onTap: disableSwap ? null : _swapTransactionType,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: disableSwap
                ? Theme.of(context).disabledColor
                : colorScheme.primaryContainer,
            child: Icon(
              Icons.swap_horiz,
              color: disableSwap
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

class ChainDropdown extends StatelessWidget {
  final String selectedChain;
  final List<String> excludeChains;
  final List<String> disabledChains;
  final ValueChanged<String> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const ChainDropdown({
    super.key,
    required this.selectedChain,
    required this.excludeChains,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
    this.disabledChains = const [],
  });

  @override
  Widget build(BuildContext context) {
    final chains = Chains.values
        .map((c) => c.name)
        .where((c) => !excludeChains.contains(c))
        .toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedChain,
        items: chains.map((c) {
          final isDisabled = disabledChains.contains(c);
          return DropdownMenuItem<String>(
            value: isDisabled ? null : c,
            enabled: !isDisabled,
            child: _ChainItem(
              chain: c,
              colorScheme: colorScheme,
              isDisabled: isDisabled,
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) => chains.map((c) {
          final isDisabled = disabledChains.contains(c);
          return _ChainItem(
            chain: c,
            colorScheme: colorScheme,
            isSelected: true,
            isDisabled: isDisabled,
          );
        }).toList(),
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    );
  }
}

class _ChainItem extends StatelessWidget {
  final String chain;
  final ColorScheme colorScheme;
  final bool isSelected;
  final bool isDisabled;

  const _ChainItem({
    required this.chain,
    required this.colorScheme,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDisabled
        ? colorScheme.onSurface.withOpacity(0.4)
        : colorScheme.onSurface;

    return Row(
      children: [
        Image.asset(
          _getChainIcon(chain),
          width: isSelected ? 30 : 20,
          height: isSelected ? 30 : 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TFT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSelected ? 14 : 12,
                color: color,
              ),
            ),
            Text(
              chain,
              style: TextStyle(
                fontSize: isSelected ? 12 : 10,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getChainIcon(String chain) {
    return {
          Chains.Stellar.name: 'assets/stellar.png',
          Chains.Solana.name: 'assets/solana.png',
          Chains.TFChain.name: 'assets/tf_chain.png',
        }[chain] ??
        'assets/tf_chain.png';
  }
}
