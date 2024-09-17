import 'package:bip39/bip39.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class NewWallet extends StatefulWidget {
  const NewWallet({
    super.key,
    required this.onAddWallet,
  });
  final Future<void> Function(SimpleWallet addedWallet) onAddWallet;

  @override
  State<StatefulWidget> createState() {
    return _NewWalletState();
  }
}

class _NewWalletState extends State<NewWallet> {
  final _nameController = TextEditingController();
  final _secretController = TextEditingController();

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: 'Invalid Input',
        description: message,
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void _validateAddSubmitData() {
    //TODO: validate name is not used
    if (_nameController.text.trim().isEmpty) {
      _showDialog("Name can't be empty");
      return;
    }
    if (_secretController.text.trim().isEmpty) {
      _showDialog("Secret can't be empty");
      return;
    }
    if (!validateMnemonic(_secretController.text.trim())) {
      _showDialog('Secret is invalid');
      return;
    }
    // TODO: save the wallet to pkid

    widget.onAddWallet(SimpleWallet(
        name: _nameController.text.trim(),
        secret: _secretController.text.trim()));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, constraints) {
      return SizedBox(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
            child: Column(
              children: [
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      decorationColor:
                          Theme.of(context).colorScheme.onBackground),
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Name')),
                  controller: _nameController,
                ),
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      decorationColor:
                          Theme.of(context).colorScheme.onBackground),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    label: Text('Secret'),
                  ),
                  controller: _secretController,
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                    const SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                        onPressed: _validateAddSubmitData,
                        child: const Text(
                            'Save')) //TODO: show loading when clicking on save
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
