import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class NewFarm extends StatefulWidget {
  const NewFarm({super.key, required this.onAddFarm, required this.wallets});
  final void Function(Farm addedFarm) onAddFarm;
  final List<Map<String, String>> wallets;

  @override
  State<StatefulWidget> createState() {
    return _NewFarmState();
  }
}

class _NewFarmState extends State<NewFarm> {
  final _nameController = TextEditingController();
  Map<String, String> _selectedWallet = {};
  bool saveLoading = false;
  String? nameError;
  Future<void> _showDialog(String title, String message, IconData icon) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CustomDialog(
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

  Future<void> _validateSubmittedData() async {
    final farmName = _nameController.text.trim();
    nameError = null;
    saveLoading = true;
    setState(() {});

    if (farmName.isEmpty) {
      nameError = "Name can't be empty";
      saveLoading = false;
      setState(() {});
      return;
    }
    //TODO: check if the farm name is used from gridproxy

    //TODO: show error for the drop down menu
    if (_selectedWallet.isEmpty) {
      saveLoading = false;
      setState(() {});
      return;
    }
    Farm farm;
    print(_selectedWallet);
    try {
      final f = await createFarm(farmName, _selectedWallet['tfchainSeed']!,
          _selectedWallet['stellarAddress']!);
      farm = Farm(
          name: farmName,
          walletAddress: _selectedWallet['stellarAddress']!,
          tfchainWalletSecret: _selectedWallet['tfchainSeed']!,
          walletName: _selectedWallet['name']!,
          twinId: f!.twinId,
          farmId: f.id,
          nodes: []);
      await _showDialog('Farm Created!',
          'Farm $farmName has been added successfully', Icons.check);
    } catch (e) {
      print(e);
      _showDialog(
          'Error', 'Failed to create farm. Please try again.', Icons.error);
      saveLoading = false;
      setState(() {});
      return;
    }
    widget.onAddFarm(farm);
    saveLoading = false;
    setState(() {});
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  List<DropdownMenuEntry<Map<String, String>>> _buildDropdownMenuEntries() {
    return widget.wallets.map((wallet) {
      return DropdownMenuEntry<Map<String, String>>(
        value: wallet,
        label: wallet['name']!,
        labelWidget: Text(wallet['name']!,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
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
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      decorationColor:
                          Theme.of(context).colorScheme.onBackground),
                  maxLength: 40,
                  decoration: InputDecoration(
                      label: const Text('Name'), errorText: nameError),
                  controller: _nameController,
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownMenu(
                  menuHeight: MediaQuery.sizeOf(context).height * 0.3,
                  enableFilter: true,
                  width: MediaQuery.sizeOf(context).width * 0.92,
                  textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
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
                    fillColor: Theme.of(context).colorScheme.secondaryContainer,
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        width: 8.0,
                      ),
                    ),
                  ),
                  menuStyle: MenuStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                  onSelected: (Map<String, String>? value) {
                    if (value != null) {
                      _selectedWallet = value;
                    }
                  },
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
                        onPressed: _validateSubmittedData,
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