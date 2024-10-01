import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/qr_code_screen.dart';
import 'package:validators/validators.dart';

class WalletReceiveScreen extends StatefulWidget {
  const WalletReceiveScreen({super.key, required this.wallet});
  final Wallet wallet;

  @override
  State<WalletReceiveScreen> createState() => _WalletReceiveScreenState();
}

class _WalletReceiveScreenState extends State<WalletReceiveScreen> {
  final toController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();
  ChainType chainType = ChainType.Stellar;
  String? amountError;

  @override
  void initState() {
    toController.text = widget.wallet.stellarAddress;
    super.initState();
  }

  @override
  void dispose() {
    toController.dispose();
    amountController.dispose();
    memoController.dispose();
    super.dispose();
  }

  bool _validate() {
    final amount = amountController.text.trim();
    amountError = null;

    if (amount.isEmpty) {
      amountError = "Amount can't be empty";
      setState(() {});
      return false;
    }

    if (!isFloat(amount)) {
      amountError = 'Amount should have numeric values only';
      setState(() {});
      return false;
    }

    return true;
  }

  _showQRCode() {
    final quaryParams = {'amount': amountController.text.trim()};
    if (chainType == ChainType.Stellar) {
      quaryParams['message'] = memoController.text.trim();
    }
    final uri = Uri(
        scheme: 'TFT',
        path: toController.text.trim(),
        queryParameters: quaryParams);
    final codeMessage = uri.toString();
    showDialog(
      context: context,
      builder: (context) => GenerateQRCodeScreen(message: codeMessage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Receive')),
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
                      toController.text = widget.wallet.stellarAddress;
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
                      toController.text = widget.wallet.tfchainAddress;
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
            ListTile(
              title: TextField(
                  readOnly: true,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                  controller: toController,
                  decoration: InputDecoration(
                    labelText: 'To (name: ${widget.wallet.name})',
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
                      suffixText: 'TFT',
                      labelText: 'Amount',
                      hintText: '100',
                      errorText: amountError)),
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
                  final valid = _validate();
                  print(valid);
                  if (valid) _showQRCode();
                },
                style: ElevatedButton.styleFrom(),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Generate QR code',
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
