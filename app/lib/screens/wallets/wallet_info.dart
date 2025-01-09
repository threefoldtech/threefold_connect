import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/wallets/warning_dialog.dart';

class WalletDetailsWidget extends StatefulWidget {
  const WalletDetailsWidget(
      {super.key,
      required this.wallet,
      required this.wallets,
      required this.onDeleteWallet,
      required this.onEditWallet});
  final Wallet wallet;
  final List<Wallet> wallets;
  final void Function(String name) onDeleteWallet;
  final void Function(String oldName, String newName) onEditWallet;

  @override
  State<WalletDetailsWidget> createState() => _WalletDetailsWidgetState();
}

class _WalletDetailsWidgetState extends State<WalletDetailsWidget> {
  final stellarSecretController = TextEditingController();
  final stellarAddressController = TextEditingController();
  final tfchainSecretController = TextEditingController();
  final tfchainAddressController = TextEditingController();
  final walletNameController = TextEditingController();
  final nameFocus = FocusNode();
  String walletName = '';
  bool showTfchainSecret = false;
  bool showStellarSecret = false;
  bool edit = false;

  @override
  void initState() {
    super.initState();
    stellarSecretController.text = widget.wallet.stellarSecret;
    stellarAddressController.text = widget.wallet.stellarAddress;
    tfchainSecretController.text = widget.wallet.tfchainSecret;
    tfchainAddressController.text = widget.wallet.tfchainAddress;
    walletNameController.text = widget.wallet.name;
    walletName = widget.wallet.name;
  }

  Future<bool> _deleteWallet() async {
    try {
      await deleteWallet(walletNameController.text);
      widget.onDeleteWallet(walletNameController.text);
      return true;
    } catch (e) {
      logger.e('Failed to delete wallet due to $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to delete',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
      return false;
    } finally {
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  String? get _errorText {
    final text = walletNameController.value.text;
    if (text.isEmpty) {
      return 'Name can\'t be empty';
    }
    final duplicateWallet = widget.wallets
        .where((element) => element.name == text && element != widget.wallet);
    if (duplicateWallet.isNotEmpty) {
      return 'Name exists';
    }

    return null;
  }

  _editWallet() async {
    setState(() {
      edit = !edit;
    });

    if (edit) {
      FocusScope.of(context).requestFocus(nameFocus);
      return;
    }

    final String newName = walletNameController.text.trim();
    if (walletName == newName) {
      setState(() {});
      return;
    }
    try {
      await editWallet(walletName, newName);
      widget.onEditWallet(walletName, newName);
      walletName = newName;
      widget.wallet.name = newName;
    } catch (e) {
      logger.e('Failed to modify wallet due to $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to Modify',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } finally {
      setState(() {});
    }
  }

  @override
  void dispose() {
    stellarSecretController.dispose();
    stellarAddressController.dispose();
    tfchainSecretController.dispose();
    tfchainAddressController.dispose();
    walletNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Addresses',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            ListTile(
              title: TextField(
                  readOnly: true,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: stellarAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Stellar',
                  )),
              trailing: IconButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: stellarAddressController.text));
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Copied!')));
                  },
                  icon: const Icon(Icons.copy)),
            ),
            ListTile(
              title: TextField(
                  readOnly: true,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: tfchainAddressController,
                  decoration: const InputDecoration(
                    labelText: 'TFChain',
                  )),
              trailing: IconButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: tfchainAddressController.text));
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Copied!')));
                  },
                  icon: const Icon(Icons.copy)),
            ),
            const SizedBox(height: 40),
            Text(
              'Secrets',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            ListTile(
              title: TextField(
                  readOnly: true,
                  obscureText: !showStellarSecret,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: stellarSecretController,
                  decoration: InputDecoration(
                    labelText: 'Stellar',
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showStellarSecret = !showStellarSecret;
                          });
                        },
                        icon: Icon(showStellarSecret
                            ? Icons.visibility
                            : Icons.visibility_off)),
                  )),
              trailing: IconButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: stellarSecretController.text));
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Copied!')));
                  },
                  icon: const Icon(Icons.copy)),
            ),
            ListTile(
              title: TextField(
                  readOnly: true,
                  obscureText: !showTfchainSecret,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: tfchainSecretController,
                  decoration: InputDecoration(
                    labelText: 'TFChain',
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showTfchainSecret = !showTfchainSecret;
                          });
                        },
                        icon: Icon(showTfchainSecret
                            ? Icons.visibility
                            : Icons.visibility_off)),
                  )),
              trailing: IconButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: tfchainSecretController.text));
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Copied!')));
                  },
                  icon: const Icon(Icons.copy)),
            ),
            const SizedBox(height: 40),
            ListTile(
              title: TextField(
                  focusNode: nameFocus,
                  autofocus: edit,
                  readOnly: !edit,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  controller: walletNameController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Wallet Name',
                    errorText: _errorText,
                  )),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (edit)
                    IconButton(
                      onPressed: _editWallet,
                      icon: const Icon(Icons.save),
                    ),
                  if (edit)
                    IconButton(
                      onPressed: _cancelEdit,
                      icon: const Icon(Icons.cancel),
                    ),
                  if (!edit)
                    IconButton(
                      onPressed: _editWallet,
                      icon: const Icon(Icons.edit),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (widget.wallet.type == WalletType.IMPORTED)
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: ElevatedButton(
                    onPressed: _showDeleteConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer),
                    child: Text(
                      'Delete',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => WarningDialogWidget(
        title: 'Are you sure?',
        description:
            'If you confirm, your wallet will be removed from this device.',
        onAgree: _deleteWallet,
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      edit = false;
      walletNameController.text = widget.wallet.name;
    });
  }
}
