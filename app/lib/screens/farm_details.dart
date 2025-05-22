import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/wallets/contacts.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/farm_node_item.dart';
import 'package:registrar_client/registrar_client.dart' as registrar;

class FarmDetails extends StatefulWidget {
  const FarmDetails({
    super.key,
    required this.farm,
    required this.wallets,
    required this.isV4,
  });

  final Farm farm;
  final List<Wallet> wallets;
  final bool isV4;

  @override
  _FarmDetailsState createState() => _FarmDetailsState();
}

class _FarmDetailsState extends State<FarmDetails> {
  final walletAddressController = TextEditingController();

  bool showTfchainSecret = false;
  bool editStellarAddress = false;
  bool isSavingStellarAddress = false;

  final walletAddressFocus = FocusNode();

  String? stellarAddressError;
  String? currentStellarAddress;

  @override
  void initState() {
    super.initState();
    currentStellarAddress = widget.farm.walletAddress;
    walletAddressController.text = currentStellarAddress!;
  }

  @override
  void dispose() {
    walletAddressController.dispose();
    walletAddressFocus.dispose();
    super.dispose();
  }

  Future<void> _validateStellarAddress(String address) async {
    setState(() {
      stellarAddressError = null;
    });

    if (address.isEmpty) {
      setState(() {
        stellarAddressError = 'Address cannot be empty';
      });
      return;
    }

    if (!isValidStellarAddress(address)) {
      setState(() {
        stellarAddressError = 'Invalid Stellar address format';
      });
      return;
    }

    try {
      final balance = await getBalanceByAccountId(address);
      if (double.parse(balance) <= -1) {
        setState(() {
          stellarAddressError = 'Wallet not activated on stellar';
        });
      }
    } catch (e) {
      logger.e('Error fetching account balance for validation: $e');
      if (stellarAddressError == null) {
        setState(() {
          stellarAddressError = 'Error validating address';
        });
      }
    }
  }

  Future<void> _saveStellarPayoutAddress() async {
    if (stellarAddressError != null ||
        walletAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(stellarAddressError ?? 'Address cannot be empty',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.errorContainer))));
      return;
    }

    setState(() {
      isSavingStellarAddress = true;
    });

    final String newAddress = walletAddressController.text.trim();
    if (newAddress == currentStellarAddress) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No changes to save.')));
      }
      setState(() {
        isSavingStellarAddress = false;
        editStellarAddress = false;
      });
      return;
    }

    try {
      final balance = await getBalanceByAccountId(newAddress);
      if (double.parse(balance) <= -1) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Wallet not activated on stellar',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.errorContainer))));
        }
        setState(() {
          isSavingStellarAddress = false;
        });
        return;
      }

      if (widget.isV4) {
        final client = registrar.RegistrarClient(
            baseUrl: Globals().registrarURL,
            mnemonicOrSeed: widget.farm.tfchainWalletSecret);
        await client.farms.update(widget.farm.twinId, widget.farm.farmId,
            stellarAddress: newAddress);
      } else {
        await addStellarAddress(
          widget.farm.tfchainWalletSecret,
          widget.farm.farmId,
          newAddress,
        );
      }

      if (context.mounted) {
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
      }

      setState(() {
        currentStellarAddress = newAddress;
        editStellarAddress = false;
      });
    } catch (e) {
      logger.e('Failed to update stellar address due to $e');
      if (context.mounted) {
        final savingAddressFailure = SnackBar(
          content: Text(
            'Failed to Update Stellar address',
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
        isSavingStellarAddress = false;
      });
    }
  }

  void _cancelStellarAddressEdit() {
    setState(() {
      editStellarAddress = false;
      walletAddressController.text = currentStellarAddress!;
      stellarAddressError = null;
    });
    walletAddressFocus.unfocus();
  }

  void _selectAddress(String address) {
    setState(() {
      walletAddressController.text = address;
      _validateStellarAddress(address.trim());
    });
  }

  Widget _buildDisplayField({
    required String label,
    required String value,
    Widget? trailing,
    bool obscureText = false,
    TextEditingController? controller,
  }) {
    final displayController = controller ?? TextEditingController(text: value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: displayController,
                readOnly: true,
                obscureText: obscureText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farm.name),
      ),
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return GestureDetector(
            onTap: () {
              if (FocusScope.of(context).hasFocus) {
                FocusScope.of(context).unfocus();
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDisplayField(
                    label: 'Farm ID',
                    value: widget.farm.farmId.toString(),
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildDisplayField(
                    label: 'Twin ID',
                    value: widget.farm.twinId.toString(),
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildDisplayField(
                    label: 'Wallet Name',
                    value: widget.farm.walletName,
                  ),
                  const Divider(height: 20, thickness: 1),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          'Stellar Payout Address',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                                focusNode: walletAddressFocus,
                                autofocus: editStellarAddress,
                                readOnly: !editStellarAddress,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: editStellarAddress
                                          ? TextOverflow.clip
                                          : TextOverflow.ellipsis,
                                    ),
                                controller: walletAddressController,
                                onChanged: (value) {
                                  if (editStellarAddress) {
                                    _validateStellarAddress(value.trim());
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: editStellarAddress
                                      ? 'Enter Stellar address'
                                      : '',
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  border: InputBorder.none,
                                  suffixIcon: editStellarAddress
                                      ? IconButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) => ContactsScreen(
                                                  chainType: ChainType.Stellar,
                                                  currentWalletAddress:
                                                      walletAddressController
                                                          .text,
                                                  wallets: widget.wallets
                                                      .where((w) =>
                                                          double.tryParse(w
                                                                  .stellarBalances['TFT']!) !=
                                                              null &&
                                                          double.parse(w
                                                                  .stellarBalances['TFT']!) >=
                                                              0)
                                                      .toList(),
                                                  onSelectToAddress:
                                                      _selectAddress),
                                            ));
                                          },
                                          icon: const Icon(Icons.person),
                                          tooltip: 'Select from Wallets',
                                        )
                                      : null,
                                )),
                          ),
                          isSavingStellarAddress
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator())
                              : editStellarAddress
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: stellarAddressError ==
                                                      null &&
                                                  walletAddressController.text
                                                      .trim()
                                                      .isNotEmpty
                                              ? _saveStellarPayoutAddress
                                              : null,
                                          icon: Icon(
                                            Icons.save,
                                            color: stellarAddressError ==
                                                        null &&
                                                    walletAddressController.text
                                                        .trim()
                                                        .isNotEmpty
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                          tooltip: 'Save Changes',
                                        ),
                                        IconButton(
                                          onPressed: _cancelStellarAddressEdit,
                                          icon:
                                              const Icon(Icons.cancel_outlined),
                                          tooltip: 'Cancel Editing',
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              editStellarAddress = true;
                                            });
                                            walletAddressFocus.requestFocus();
                                            walletAddressController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        walletAddressController
                                                            .text.length);
                                          },
                                          icon: const Icon(Icons.edit),
                                          tooltip: 'Edit Address',
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: walletAddressController
                                                    .text));
                                            ScaffoldMessenger.of(context)
                                                .clearSnackBars();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text('Copied!')));
                                          },
                                          icon: const Icon(Icons.copy),
                                          tooltip: 'Copy Address',
                                        ),
                                      ],
                                    ),
                        ],
                      ),
                      if (stellarAddressError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            stellarAddressError!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                      Text(
                        'This address will be used for payout.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1),
                  if (!widget.isV4) ...[
                    _buildDisplayField(
                      label: 'TFChain Secret',
                      value: widget.farm.tfchainWalletSecret,
                      obscureText: !showTfchainSecret,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                showTfchainSecret = !showTfchainSecret;
                              });
                            },
                            icon: Icon(showTfchainSecret
                                ? Icons.visibility
                                : Icons.visibility_off),
                            tooltip: showTfchainSecret
                                ? 'Hide Secret'
                                : 'Show Secret',
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: widget.farm.tfchainWalletSecret));
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied!')));
                            },
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy Secret',
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Use this secret to log in to the ThreeFold Dashboard.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  if (widget.farm.nodes.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 20, thickness: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Nodes (${widget.farm.nodes.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.farm.nodes.length,
                          itemBuilder: (context, index) {
                            final node = widget.farm.nodes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 0.0),
                              elevation: 1.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1.0,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: FarmNodeItemWidget(
                                node: node,
                                isV4: widget.isV4,
                                farmName: widget.farm.name,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
