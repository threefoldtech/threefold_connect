import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class SelectChainWidget extends StatelessWidget {
  const SelectChainWidget(
      {super.key, required this.chainType, required this.onChangeChain});
  final void Function(ChainType chainType) onChangeChain;
  final ChainType chainType;

  Widget _optionButton(BuildContext context, String label, double width,
      bool active, void Function() onPressed) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          fixedSize: Size.fromWidth(width),
          backgroundColor:
              active ? colorScheme.primaryContainer : colorScheme.background,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(
                  color: active
                      ? colorScheme.primaryContainer
                      : colorScheme.secondaryContainer))),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: active
                ? colorScheme.onPrimaryContainer
                : colorScheme.onBackground),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _optionButton(
              context, 'Stellar', width / 3, chainType == ChainType.Stellar,
              () {
            onChangeChain(ChainType.Stellar);
          }),
          _optionButton(
              context, 'TFChain', width / 3, chainType == ChainType.TFChain,
              () {
            onChangeChain(ChainType.TFChain);
          }),
        ],
      ),
    );
  }
}
