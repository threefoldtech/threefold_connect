import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class NewFarm extends StatefulWidget {
  const NewFarm({super.key, required this.onAddFarm, required this.wallets});
  final void Function(Farm addedFarm) onAddFarm;
  final List<Wallet> wallets;

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

  Future<bool> _validateName(String farmName) async {
    nameError = null;
    walletError = null;

    if (farmName.isEmpty) {
      nameError = "Name can't be empty";
      return false;
    }
    final available = await isFarmNameAvailable(farmName);

    if (!available) {
      nameError = 'Farm name is already used';
      return false;
    }
    return true;
  }

  bool _validateWallet() {
    if (_selectedWallet == null) {
      walletError = 'Please select a wallet';
      return false;
    }
    return true;
  }

  _add(String farmName) async {
    Farm farm;
    try {
      final f = await createFarm(farmName, _selectedWallet!.tfchainSecret,
          _selectedWallet!.stellarAddress);
      farm = Farm(
          name: farmName,
          walletAddress: _selectedWallet!.stellarAddress,
          tfchainWalletSecret: _selectedWallet!.tfchainSecret,
          walletName: _selectedWallet!.name,
          twinId: f!.twinId,
          farmId: f.id,
          nodes: []);
      await _showDialog(
          'Farm Created!',
          'Farm $farmName has been added successfully',
          Icons.check,
          DialogType.Info);
    } catch (e) {
      logger.e(e);
      _showDialog('Error', 'Failed to create farm. Please try again.',
          Icons.error, DialogType.Error);
      return;
    }
    widget.onAddFarm(farm);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> _validateAndAdd() async {
    final farmName = _nameController.text.trim();
    saveLoading = true;
    setState(() {});
    final validName = await _validateName(farmName);
    final validWallet = _validateWallet();
    if (validName && validWallet) {
      await _add(farmName);
    }
    saveLoading = false;
    setState(() {});
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
                Text(
                  'Create Farm',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      decorationColor: Theme.of(context).colorScheme.onSurface),
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
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
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
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          width: 8.0,
                        ),
                      ),
                    ),
                    menuStyle: MenuStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                    label: Text(
                      'Select Wallet',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                    dropdownMenuEntries: _buildDropdownMenuEntries(),
                    onSelected: (Wallet? value) {
                      if (value != null) {
                        _selectedWallet = value;
                      }
                    },
                  ),
                if (widget.wallets.isEmpty)
                  Text(
                    'Please initiate the first wallet or import a wallet.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Theme.of(context).colorScheme.error),
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
        ),
      );
    });
  }
}
