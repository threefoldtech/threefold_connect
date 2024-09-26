import 'package:flutter/material.dart';
import 'package:threebotlogin/models/wallet.dart';

class SendConfirmationWidget extends StatefulWidget {
  const SendConfirmationWidget({
    super.key,
    required this.chainType,
    required this.from,
    required this.to,
    required this.amount,
    required this.memo,
  });

  final ChainType chainType;
  final String from;
  final String to;
  final String amount;
  final String memo;

  @override
  State<SendConfirmationWidget> createState() => _SendConfirmationWidgetState();
}

class _SendConfirmationWidgetState extends State<SendConfirmationWidget> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();

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
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
          ListTile(
            title: TextField(
                readOnly: true,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
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
                readOnly: true,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
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
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                  controller: memoController,
                  decoration: const InputDecoration(
                    labelText: 'Memo',
                  )),
            ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: ElevatedButton(
              onPressed: () async {},
              style: ElevatedButton.styleFrom(),
              child: SizedBox(
                width: double.infinity,
                child: Text(
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
}
