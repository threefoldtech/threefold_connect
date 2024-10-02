import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class SelectChainWidget extends StatefulWidget {
  const SelectChainWidget({super.key, required this.onChangeChain});
  final void Function(ChainType chainType) onChangeChain;

  @override
  State<SelectChainWidget> createState() => _SelectChainWidgetState();
}

class _SelectChainWidgetState extends State<SelectChainWidget> {
  ChainType chainType = ChainType.Stellar;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              chainType = ChainType.Stellar;
              widget.onChangeChain(chainType);
            },
            style: ElevatedButton.styleFrom(
                fixedSize: Size.fromWidth(width / 3),
                backgroundColor: chainType == ChainType.Stellar
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                    side: BorderSide(
                        color: chainType == ChainType.Stellar
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .secondaryContainer))),
            child: Text(
              'Stellar',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: chainType == ChainType.Stellar
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onBackground),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              chainType = ChainType.TFChain;
              widget.onChangeChain(chainType);
            },
            style: ElevatedButton.styleFrom(
                fixedSize: Size.fromWidth(width / 3),
                backgroundColor: chainType == ChainType.TFChain
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                        color: chainType == ChainType.TFChain
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .secondaryContainer))),
            child: Text(
              'TFChain',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: chainType == ChainType.TFChain
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onBackground),
            ),
          ),
        ],
      ),
    );
  }
}
