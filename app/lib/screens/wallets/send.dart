import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

enum ChainType {
  Stellar,
  TFChain,
}

class WalletSendScreen extends StatefulWidget {
  const WalletSendScreen({super.key, required this.wallet});
  final Wallet wallet;
  @override
  State<WalletSendScreen> createState() => _WalletSendScreenState();
}

class _WalletSendScreenState extends State<WalletSendScreen> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();
  ChainType chainType = ChainType.Stellar;

  @override
  void initState() {
    fromController.text = widget.wallet.stellarAddress;
    super.initState();
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    amountController.dispose();
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {
                      fromController.text = widget.wallet.stellarAddress;
                      chainType = ChainType.Stellar;
                    }),
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size.fromWidth(width / 3),
                        backgroundColor: chainType == ChainType.Stellar
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.background,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                            side: BorderSide(
                                color: chainType == ChainType.Stellar
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
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
                    onPressed: () => setState(() {
                      fromController.text = widget.wallet.tfchainAddress;
                      chainType = ChainType.TFChain;
                    }),
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size.fromWidth(width / 3),
                        backgroundColor: chainType == ChainType.TFChain
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.background,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                                color: chainType == ChainType.TFChain
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
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
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: TextButton(
                onPressed: () {
                  //TODO: Scan qr code
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Scan QR code',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: TextField(
                  readOnly: true,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                  controller: fromController,
                  decoration: InputDecoration(
                    labelText: 'From (name: ${widget.wallet.name})',
                  )),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                  controller: toController,
                  decoration: const InputDecoration(
                    labelText: 'To',
                  )),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  decoration: InputDecoration(
                      labelText:
                          'Amount (Balance: ${chainType == ChainType.Stellar ? widget.wallet.stellarBalance : widget.wallet.tfchainBalance})',
                      hintText: '100')),
            ),
            const SizedBox(height: 10),
            if (chainType == ChainType.Stellar)
              ListTile(
                title: TextField(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                    controller: memoController,
                    decoration: const InputDecoration(
                      labelText: 'Memo',
                    )),
              ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: ElevatedButton(
                onPressed: () {
                  //TODO: Show confirmation page
                },
                style: ElevatedButton.styleFrom(),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Transfer',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
