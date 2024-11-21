import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart' as Stellar;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChain;
import 'package:threebotlogin/widgets/custom_dialog.dart';

class SendConfirmationWidget extends StatefulWidget {
  const SendConfirmationWidget({
    super.key,
    required this.chainType,
    required this.secret,
    required this.from,
    required this.to,
    required this.amount,
    required this.memo,
    required this.reloadBalance,
  });

  final ChainType chainType;
  final String secret;
  final String from;
  final String to;
  final String amount;
  final String memo;
  final void Function() reloadBalance;

  @override
  State<SendConfirmationWidget> createState() => _SendConfirmationWidgetState();
}

class _SendConfirmationWidgetState extends State<SendConfirmationWidget> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    fromController.text = widget.from;
    toController.text = widget.to;
    amountController.text = widget.amount;
    memoController.text = widget.memo;
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(
            'Send Confirmation',
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
                'Max Fee: ${widget.chainType == ChainType.Stellar ? 0.1 : 0.01} TFT'),
          ),
          const SizedBox(height: 10),
          if (widget.chainType == ChainType.Stellar)
            ListTile(
              title: TextField(
                  readOnly: true,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: memoController,
                  decoration: const InputDecoration(
                    labelText: 'Memo',
                  )),
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
      if (widget.chainType == ChainType.Stellar) {
        await Stellar.transfer(
            widget.secret, widget.to, widget.amount, widget.memo);
      } else {
        await TFChain.transfer(widget.secret, widget.to, widget.amount);
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
