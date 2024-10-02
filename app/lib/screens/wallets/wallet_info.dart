import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class WalletDetailsWidget extends StatefulWidget {
  const WalletDetailsWidget(
      {super.key,
      required this.wallet,
      required this.onDeleteWallet,
      required this.onEditWallet});
  final Wallet wallet;
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
  bool deleteLoading = false;
  bool edit = false;

  Future<bool> _deleteWallet() async {
    setState(() {
      deleteLoading = true;
    });
    try {
      await deleteWallet(walletNameController.text);
      widget.onDeleteWallet(walletNameController.text);
      return true;
    } catch (e) {
      print('Failed to delete wallet due to $e');
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
      setState(() {
        deleteLoading = false;
      });
    }
  }

  _editWallet() async {
    edit = !edit;
    final String newName = walletNameController.text.trim();
    if (walletName == newName) {
      FocusScope.of(context).requestFocus(nameFocus);
      setState(() {});
      return;
    }
    try {
      await editWallet(walletName, newName);
      widget.onEditWallet(walletName, newName);
      walletName = newName;
      widget.wallet.name = newName;
    } catch (e) {
      print('Failed to modify wallet due to $e');
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
    stellarSecretController.text = widget.wallet.stellarSecret;
    stellarAddressController.text = widget.wallet.stellarAddress;
    tfchainSecretController.text = widget.wallet.tfchainSecret;
    tfchainAddressController.text = widget.wallet.tfchainAddress;
    walletNameController.text = widget.wallet.name;
    walletName = widget.wallet.name;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Addresses',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            ListTile(
              title: TextField(
                  readOnly: true,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
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
                        color: Theme.of(context).colorScheme.onBackground,
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
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            ListTile(
              title: TextField(
                  readOnly: true,
                  obscureText: !showStellarSecret,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
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
                        color: Theme.of(context).colorScheme.onBackground,
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
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                  controller: walletNameController,
                  decoration: const InputDecoration(
                    labelText: 'Wallet Name',
                  )),
              trailing: IconButton(
                  onPressed: _editWallet,
                  icon: edit ? const Icon(Icons.save) : const Icon(Icons.edit)),
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
                    child: deleteLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.error,
                            ))
                        : Text(
                            'Delete',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
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
      builder: (BuildContext context) => CustomDialog(
        type: DialogType.Warning,
        image: Icons.warning,
        title: 'Are you sure?',
        description:
            'If you confirm, your wallet will be removed from this device.',
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            onPressed: () async {
              final deleted = await _deleteWallet();
              if (context.mounted) {
                Navigator.pop(context);
                if (deleted) Navigator.pop(context);
              }
            },
            //TODO: show loading when press yes
            child: Text(
              'Yes',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).colorScheme.warning),
            ),
          ),
        ],
      ),
    );
  }
}
