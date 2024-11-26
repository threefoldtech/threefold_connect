import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart' as Stellar;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChain;
import 'package:threebotlogin/widgets/custom_dialog.dart';

class BridgeConfirmationWidget extends StatefulWidget {
  const BridgeConfirmationWidget({
    super.key,
    required this.transactionType,
    required this.secret,
    required this.from,
    required this.to,
    required this.amount,
    required this.memo,
    required this.reloadBalance,
  });

  final TransactionType transactionType;
  final String secret;
  final String from;
  final String to;
  final String amount;
  final String memo;
  final void Function() reloadBalance;

  @override
  State<BridgeConfirmationWidget> createState() =>
      _BridgeConfirmationWidgetState();
}

class _BridgeConfirmationWidgetState extends State<BridgeConfirmationWidget> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final amountController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    fromController.text = widget.from;
    toController.text = widget.to;
    amountController.text = widget.amount;
    super.initState();
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(
            widget.transactionType == TransactionType.Withdraw
                ? 'Withdraw Confirmation'
                : 'Deposit Confirmation',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          ListTile(
            title: TextField(
                readOnly: true,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                controller: fromController,
                decoration: const InputDecoration(
                  labelText: 'From',
                )),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: TextField(
                readOnly: true,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                controller: toController,
                decoration: const InputDecoration(
                  labelText: 'To',
                )),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: TextField(
                readOnly: true,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                keyboardType: TextInputType.number,
                controller: amountController,
                decoration: const InputDecoration(
                    labelText: 'Amount', hintText: '100', suffixText: 'TFT')),
            subtitle: Text(
                'Max Fee: ${widget.transactionType == TransactionType.Deposit ? 1.1 : 1.01} TFT'),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _send,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ))
                    : Text(
                        'Confirm',
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
    );
  }

  _send() async {
    setState(() {
      loading = true;
    });
    try {
      if (widget.transactionType == TransactionType.Deposit) {
        await Stellar.transfer(widget.secret, Globals().bridgeTFTAddress,
            widget.amount, widget.memo);
      } else {
        await TFChain.swapToStellar(
            widget.secret, widget.to, BigInt.from(double.parse(widget.amount)));
      }
      await _showDialog('Success!', 'Tokens have been transferred successfully',
          Icons.check, DialogType.Info);
    } catch (e) {
      _showDialog('Error', 'Failed to transfer. Please try again.', Icons.error,
          DialogType.Error);
      setState(() {
        loading = false;
      });
      return;
    }

    setState(() {
      loading = false;
    });
    widget.reloadBalance();
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> _showDialog(
      String title, String message, IconData icon, DialogType type) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: type,
        image: icon,
        title: title,
        description: message,
      ),
    );
    await Future.delayed(
      const Duration(seconds: 3),
      () {
        Navigator.pop(context);
      },
    );
  }
}
