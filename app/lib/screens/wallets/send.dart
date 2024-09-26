import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/scan_screen.dart';
import 'package:threebotlogin/widgets/wallets/send_confirmation.dart';

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
  // TODO: Add validation on all fields

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
                  scanQrCode();
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
                      hintText: '100',
                      suffixText: 'TFT')),
              subtitle: Text(
                  'Max Fee: ${chainType == ChainType.Stellar ? 0.1 : 0.01} TFT'),
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
                onPressed: () async {
                  // TODO: Trigger validation here
                  await _send_confirmation();
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

  scanQrCode() async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    // QRCode scanner is black if we don't sleep here.
    bool slept =
        await Future.delayed(const Duration(milliseconds: 400), () => true);
    late Barcode result;
    if (slept) {
      if (context.mounted) {
        result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ScanScreen()));
      }
    }
    if (result.code != null) {
      final code = Uri.parse(result.code!);
      toController.text = code.path;
      if (code.queryParameters.containsKey('amount')) {
        amountController.text = code.queryParameters['amount']!;
      }
      if (chainType == ChainType.Stellar &&
          code.queryParameters.containsKey('message')) {
        memoController.text = code.queryParameters['message']!;
      }
      setState(() {});
    }

    return result.code;
  }

  _send_confirmation() async {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => SendConfirmationWidget(
              chainType: chainType,
              from: fromController.text,
              to: toController.text,
              amount: amountController.text,
              memo: memoController.text,
            ));
  }
}
