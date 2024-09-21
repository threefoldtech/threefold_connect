import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/wallet_service.dart';

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

  _deleteWallet() async {
    setState(() {
      deleteLoading = true;
    });
    await deleteWallet(walletNameController.text);
    widget.onDeleteWallet(walletNameController.text);
    if (context.mounted) {
      Navigator.pop(context);
    }

    setState(() {
      deleteLoading = false;
    });
  }

  _editWallet() async {
    edit = !edit;
    if (walletName == walletNameController.text) {
      FocusScope.of(context).requestFocus(nameFocus);
      setState(() {});
      return;
    }
    await editWallet(walletName, walletNameController.text);
    widget.onEditWallet(walletName, walletNameController.text);
    walletName = walletNameController.text;
    widget.wallet.name = walletName;
    setState(() {});
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
            if (widget.wallet.type == WalletType.Imported)
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: ElevatedButton(
                    onPressed: _deleteWallet,
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
}
