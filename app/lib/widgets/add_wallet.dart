import 'package:bip39/bip39.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class NewWallet extends StatefulWidget {
  const NewWallet({
    super.key,
    required this.onAddWallet,
  });
  final void Function(Wallet addedWallet) onAddWallet;

  @override
  State<StatefulWidget> createState() {
    return _NewWalletState();
  }
}

class _NewWalletState extends State<NewWallet> {
  final _nameController = TextEditingController();
  final _secretController = TextEditingController();
  bool saveLoading = false;

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

  Future<void> _validateAddSubmitData() async {
    //TODO: validate name is not used

    final walletName = _nameController.text.trim();
    final walletSecret = _secretController.text.trim();
    if (walletName.isEmpty) {
      _showDialog("Name can't be empty");
      return;
    }
    if (walletSecret.isEmpty) {
      _showDialog("Secret can't be empty");
      return;
    }
    if (!validateMnemonic(walletSecret)) {
      _showDialog('Secret is invalid');
      return;
    }
    saveLoading = true;
    setState(() {});
    final wallet = await loadAddWallet(walletName, walletSecret);

    widget.onAddWallet(wallet);
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
                        child: saveLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ))
                            : const Text('Save'))
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

Future<Wallet> loadAddWallet(String walletName, String walletSecret) async {
  final chainUrl = Globals().chainUrl;
  final Wallet wallet = await compute((void _) async {
    final wallet = await loadWallet(
        walletName, walletSecret, WalletType.Imported, chainUrl);
    return wallet;
  }, null);
  return wallet;
}
