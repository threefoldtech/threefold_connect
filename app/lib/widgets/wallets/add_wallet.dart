import 'package:bip39/bip39.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:tfchain_client/src/utils.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class NewWallet extends StatefulWidget {
  const NewWallet(
      {super.key, required this.onAddWallet, required this.wallets});
  final void Function(Wallet addedWallet) onAddWallet;
  final List<Wallet> wallets;

  @override
  State<StatefulWidget> createState() {
    return _NewWalletState();
  }
}

class _NewWalletState extends State<NewWallet> {
  final _nameController = TextEditingController();
  final _secretController = TextEditingController();
  bool saveLoading = false;
  String? nameError;
  String? secretError;
  Future<void> _showDialog(String title, String message, IconData icon, DialogType type) async {
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

  Future<void> _validateAddSubmitData() async {
    final walletName = _nameController.text.trim();
    final walletSecret = _secretController.text.trim();
    nameError = null;
    secretError = null;
    saveLoading = true;
    setState(() {});

    if (walletName.isEmpty) {
      nameError = "Name can't be empty";
      saveLoading = false;
      setState(() {});
      return;
    }
    final w = widget.wallets.where((element) => element.name == walletName);
    if (w.isNotEmpty) {
      nameError = 'Name exists';
      saveLoading = false;
      setState(() {});
      return;
    }
    if (walletSecret.isEmpty) {
      secretError = "Secret can't be empty";
      saveLoading = false;
      setState(() {});
      return;
    }
    if (!(validateMnemonic(walletSecret) ||
        (!validateMnemonic(walletSecret) && walletSecret.contains(' ')) ||
        (isValidStellarSecret(walletSecret)) ||
        (isValidSeed(walletSecret) &&
            ((!walletSecret.startsWith('0x') && walletSecret.length == 64) ||
                (walletSecret.startsWith('0x') &&
                    walletSecret.length == 66))))) {
      secretError = 'Secret is invalid';
      saveLoading = false;
      setState(() {});
      return;
    }
    Wallet wallet;
    try {
      wallet = await loadAddedWallet(walletName, walletSecret);
    } catch (e) {
      print(e);
      _showDialog(
          'Error', 'Failed to load wallet. Please try again.', Icons.error, DialogType.Error);
      saveLoading = false;
      setState(() {});
      return;
    }
    try {
      await addWallet(walletName, walletSecret);
      await _showDialog('Wallet Added!',
          'Wallet $walletName has been added successfully', Icons.check, DialogType.Info);
    } catch (e) {
      print(e);
      _showDialog(
          'Error', 'Failed to save wallet. Please try again.', Icons.error, DialogType.Error);
      saveLoading = false;
      setState(() {});
      return;
    }
    widget.onAddWallet(wallet);
    saveLoading = false;
    setState(() {});
    if (!context.mounted) return;
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
                  decoration: InputDecoration(
                      label: const Text('Name'), errorText: nameError),
                  controller: _nameController,
                ),
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      decorationColor:
                          Theme.of(context).colorScheme.onBackground),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    label: const Text('Secret'),
                    errorText: secretError,
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
                          if (saveLoading) return;
                          Navigator.pop(context);
                        },
                        child: const Text('Close')),
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

Future<Wallet> loadAddedWallet(String walletName, String walletSecret) async {
  final chainUrl = Globals().chainUrl;
  final Wallet wallet = await compute((void _) async {
    final wallet = await loadWallet(
        walletName, walletSecret, WalletType.IMPORTED, chainUrl);
    return wallet;
  }, null);
  return wallet;
}
