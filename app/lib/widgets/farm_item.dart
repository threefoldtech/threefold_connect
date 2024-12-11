import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/wallets/contacts.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/farm_node_item.dart';

class FarmItemWidget extends StatefulWidget {
  const FarmItemWidget({super.key, required this.farm, required this.wallets});
  final Farm farm;
  final List<Wallet> wallets;

  @override
  State<FarmItemWidget> createState() => _FarmItemWidgetState();
}

class _FarmItemWidgetState extends State<FarmItemWidget> {
  final walletAddressController = TextEditingController();
  final tfchainWalletSecretController = TextEditingController();
  final walletNameController = TextEditingController();
  final twinIdController = TextEditingController();
  final farmIdController = TextEditingController();
  bool showTfchainSecret = false;
  bool edit = false;
  bool isSaving = false;
  final walletFocus = FocusNode();
  ChainType chainType = ChainType.Stellar;
  String? addressError;

  @override
  void initState() {
    super.initState();
    walletAddressController.text = widget.farm.walletAddress;
  }

  @override
  void dispose() {
    walletAddressController.dispose();
    tfchainWalletSecretController.dispose();
    walletNameController.dispose();
    twinIdController.dispose();
    farmIdController.dispose();
    super.dispose();
  }

  _editStellarPayoutAddress() async {
    setState(() {
      isSaving = true;
    });

    final String newAddress = walletAddressController.text.trim();
    if (newAddress == widget.farm.walletAddress) {
      FocusScope.of(context).requestFocus(walletFocus);
      setState(() {
        isSaving = false;
        edit = false;
      });
      return;
    }

    try {
      await addStellarAddress(
        widget.farm.tfchainWalletSecret,
        widget.farm.farmId,
        newAddress,
      );
      final savingAddressSuccess = SnackBar(
        content: Text(
          'Address is saved Successfully.',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.surface,
              ),
        ),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(savingAddressSuccess);
    } catch (e) {
      logger.e('Failed to add stellar address due to $e');
      if (context.mounted) {
        final savingAddressFailure = SnackBar(
          content: Text(
            'Failed to Add Stellar address',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.errorContainer,
                ),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(savingAddressFailure);
      }
    } finally {
      setState(() {
        edit = false;
        isSaving = false;
      });
    }
  }

  void validateStellarAddress(String address) async {
    setState(() {
      addressError =
          isValidStellarAddress(address) ? null : 'Invalid Stellar address';
    });

    if (addressError == null) {
      try {
        final balance = await getBalanceByAccountId(address);
        if (balance == '-1') {
          setState(() {
            addressError = 'Wallet not activated on stellar';
          });
        }
      } catch (e) {
        setState(() {
          addressError = 'Error fetching account balance';
        });
      }
    }
  }

  void _selectToAddress(String address) {
    setState(() {
      walletAddressController.text = address;
      validateStellarAddress(address);
    });
  }

  void _cancelEdit() {
    setState(() {
      edit = false;
      walletAddressController.text = widget.farm.walletAddress;
      addressError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    tfchainWalletSecretController.text = widget.farm.tfchainWalletSecret;
    walletNameController.text = widget.farm.walletName;
    farmIdController.text = widget.farm.farmId.toString();
    twinIdController.text = widget.farm.twinId.toString();

    return ExpansionTile(
      title: Text(
        widget.farm.name,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        ListTile(
          title: TextField(
              focusNode: walletFocus,
              autofocus: edit,
              readOnly: !edit,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              controller: walletAddressController,
              onChanged: (value) {
                validateStellarAddress(value);
              },
              decoration: InputDecoration(
                  errorText: addressError,
                  labelText: 'Stellar Payout Address',
                  suffixIcon: edit
                      ? IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ContractsScreen(
                                  chainType: chainType,
                                  currentWalletAddress:
                                      widget.farm.walletAddress,
                                  wallets: widget.wallets
                                      .where((w) =>
                                          double.parse(w.stellarBalance) >= 0 &&
                                          w.stellarAddress !=
                                              widget.farm.walletAddress)
                                      .toList(),
                                  onSelectToAddress: _selectToAddress),
                            ));
                          },
                          icon: const Icon(Icons.person))
                      : null)),
          subtitle: const Text('This address will be used for payout.'),
          trailing: isSaving
              ? Transform.scale(
                  scale: 0.5, child: const CircularProgressIndicator())
              : edit
                  ? SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: addressError == null
                                ? () {
                                    _editStellarPayoutAddress();
                                  }
                                : null,
                            icon: Icon(
                              Icons.save,
                              color: addressError == null
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),
                          IconButton(
                            onPressed: _cancelEdit,
                            icon: const Icon(
                              Icons.cancel_outlined,
                            ),
                          )
                        ],
                      ),
                    )
                  : SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  edit = !edit;
                                });
                                if (edit) {
                                  FocusScope.of(context)
                                      .requestFocus(walletFocus);
                                }
                              },
                              icon: edit
                                  ? const Icon(Icons.save)
                                  : const Icon(Icons.edit)),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: walletAddressController.text));
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied!')));
                            },
                            icon: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                    ),
        ),
        ListTile(
          title: TextField(
              readOnly: true,
              obscureText: !showTfchainSecret,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              controller: tfchainWalletSecretController,
              decoration: InputDecoration(
                labelText: 'TFChain Secret',
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
          subtitle: const Text(
              'You can login into ThreeFold Dashboard using this secret for more farm management.'),
          trailing: IconButton(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: tfchainWalletSecretController.text));
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
              controller: walletNameController,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
              )),
        ),
        ListTile(
          title: TextField(
              readOnly: true,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              controller: twinIdController,
              decoration: const InputDecoration(
                labelText: 'Twin ID',
              )),
        ),
        ListTile(
          title: TextField(
              readOnly: true,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              controller: farmIdController,
              decoration: const InputDecoration(
                labelText: 'Farm ID',
              )),
        ),
        ExpansionTile(
          title: const Text('Nodes'),
          childrenPadding: const EdgeInsets.only(left: 20),
          children: [
            for (final node in widget.farm.nodes) FarmNodeItemWidget(node: node)
          ],
        )
      ],
    );
  }
}
