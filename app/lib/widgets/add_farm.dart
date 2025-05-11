import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:registrar_client/models/account.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:registrar_client/registrar_client.dart' as registrar;
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:tfchain_client/generated/dev/types/tfchain_support/types/farm.dart'
    as ChainFarm;
import 'package:validators/validators.dart';

class NewFarm extends StatefulWidget {
  const NewFarm(
      {super.key,
      required this.onAddFarm,
      required this.wallets,
      required this.isV4});
  final void Function(Farm addedFarm) onAddFarm;
  final List<Wallet> wallets;
  final bool isV4;
  @override
  State<StatefulWidget> createState() {
    return _NewFarmState();
  }
}

class _NewFarmState extends State<NewFarm> {
  final _nameController = TextEditingController();
  Wallet? _selectedWallet;
  bool saveLoading = false;
  String? nameError;
  String? walletError;
  late registrar.RegistrarClient? registrarClient;

  Future<void> _initRegistrar(String mnemonicOrSeed) async {
    registrarClient = registrar.RegistrarClient(
        baseUrl: Globals().registrarURL, mnemonicOrSeed: mnemonicOrSeed);
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

  Future<bool> isV4FarmAvailable(String name) async {
    try {
      final farms = await registrarClient!.farms
          .list(registrar.FarmFilter(farmName: name));
      return farms.isEmpty;
    } catch (e) {
      throw Exception('Failed to list farm due to: $e');
    }
  }

  Future<bool> _validateName(String farmName) async {
    late bool available;
    nameError = null;
    walletError = null;

    if (farmName.isEmpty) {
      nameError = "Name can't be empty";
      return false;
    }
    if (farmName.contains(' ')) {
      nameError = "Name can't contain spaces";
      return false;
    }

    if (widget.isV4) {
      if (!isAlphanumeric(farmName)) {
        nameError = 'Name can only include letters and numbers';
        return false;
      }
      available = await isV4FarmAvailable(farmName);
    } else {
      available = await isFarmNameAvailable(farmName);
    }

    if (!available) {
      nameError = 'Farm name is already used';
      return false;
    }
    return true;
  }

  bool _validateWallet() {
    if (_selectedWallet == null) {
      setState(() {
        walletError = 'Please select a wallet';
      });
      return false;
    }
    if (double.parse(_selectedWallet!.stellarBalance) <= -1) {
      setState(() {
        walletError = 'Wallet not activated on stellar';
      });
      return false;
    }
    return true;
  }

  Future<registrar.Farm> addV4Farm(String farmName) async {
    Account? account;
    try {
      final publicKey = await derivePublicKey(_selectedWallet!.tfchainSecret);
      account = await registrarClient!.accounts.getByPublicKey(publicKey);
    } catch (e) {
      account = await registrarClient!.accounts.create();
    }
    final v4FarmId = await registrarClient!.farms.create(
        farmName, false, _selectedWallet!.stellarAddress, account.twinID);
    return await registrarClient!.farms.get(v4FarmId);
  }

  _add(String farmName) async {
    late Farm farm;
    late ChainFarm.Farm v3Farm;
    late registrar.Farm v4Farm;
    try {
      if (widget.isV4) {
        v4Farm = await addV4Farm(farmName);
      } else {
        v3Farm = (await createFarm(farmName, _selectedWallet!.tfchainSecret,
            _selectedWallet!.stellarAddress))!;
      }
      farm = Farm(
          name: farmName,
          walletAddress: _selectedWallet!.stellarAddress,
          tfchainWalletSecret: _selectedWallet!.tfchainSecret,
          walletName: _selectedWallet!.name,
          twinId: widget.isV4 ? v4Farm.twinID : v3Farm.twinId,
          farmId: widget.isV4 ? v4Farm.farmID! : v3Farm.id,
          nodes: []);
      await _showDialog(
          'Farm Created!',
          'Farm $farmName has been added successfully',
          Icons.check,
          DialogType.Info);
      widget.onAddFarm(farm);
    } catch (e) {
      logger.e('Failed to add farm: $e');
      _showDialog('Error', 'Failed to create farm. Please try again.',
          Icons.error, DialogType.Error);
      return;
    }
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> _validateAndAdd() async {
    if (!_validateWallet()) return;
    final farmName = _nameController.text.trim();
    setState(() {
      saveLoading = true;
    });
    final validName = await _validateName(farmName);
    if (validName) {
      await _add(farmName);
    }
    setState(() {
      saveLoading = false;
    });
  }

  List<DropdownMenuEntry<Wallet>> _buildDropdownMenuEntries() {
    return widget.wallets.map((wallet) {
      return DropdownMenuEntry<Wallet>(
        value: wallet,
        label: wallet.name,
        labelWidget: Text(wallet.name,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                )),
      );
    }).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    registrarClient = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, constraints) {
      return SizedBox(child:
          KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
                child: Column(
                  children: [
                    Text(
                      'Create Farm',
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          decorationColor:
                              Theme.of(context).colorScheme.onSurface),
                      maxLength: 40,
                      decoration: InputDecoration(
                          label: const Text('Name'), errorText: nameError),
                      controller: _nameController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.wallets.isNotEmpty)
                      DropdownMenu(
                        menuHeight: MediaQuery.sizeOf(context).height * 0.3,
                        enableFilter: true,
                        errorText: walletError,
                        width: MediaQuery.sizeOf(context).width * 0.92,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        trailingIcon: const Icon(
                          CupertinoIcons.chevron_down,
                          size: 18,
                        ),
                        selectedTrailingIcon: const Icon(
                          CupertinoIcons.chevron_up,
                          size: 18,
                        ),
                        inputDecorationTheme: InputDecorationTheme(
                          filled: true,
                          fillColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          enabledBorder: UnderlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              width: 8.0,
                            ),
                          ),
                        ),
                        menuStyle: MenuStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                        ),
                        label: Text(
                          'Select Wallet',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                        ),
                        dropdownMenuEntries: _buildDropdownMenuEntries(),
                        onSelected: (Wallet? value) async {
                          if (value != null) {
                            _selectedWallet = value;
                            await _initRegistrar(
                                _selectedWallet!.tfchainSecret);
                          }
                        },
                      ),
                    if (widget.wallets.isEmpty)
                      Text(
                        'Please initiate the first wallet or import a wallet.',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.error),
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
                            onPressed: _validateAndAdd,
                            child: saveLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ))
                                : const Text('Create'))
                      ],
                    ),
                  ],
                ),
              ),
            ));
      }));
    });
  }
}
