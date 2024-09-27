import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/models/contact.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/contact_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class NewContact extends StatefulWidget {
  const NewContact(
      {super.key,
      required this.onAddContact,
      required this.contacts,
      required this.chainType});
  final void Function(PkidContact addedContact) onAddContact;
  final List<PkidContact> contacts;
  final ChainType chainType;

  @override
  State<StatefulWidget> createState() {
    return _NewContactState();
  }
}

class _NewContactState extends State<NewContact> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  bool saveLoading = false;
  String? nameError;
  String? addressError;
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

  Future<void> _validateAddSubmitData() async {
    final contactName = _nameController.text.trim();
    final contactAddress = _addressController.text.trim();
    nameError = null;
    addressError = null;
    saveLoading = true;
    setState(() {});

    if (contactName.isEmpty) {
      nameError = "Name can't be empty";
      saveLoading = false;
      setState(() {});
      return;
    }
    final c = widget.contacts.where((element) => element.name == contactName);
    if (c.isNotEmpty) {
      nameError = 'Name exists';
      saveLoading = false;
      setState(() {});
      return;
    }
    if (contactAddress.isEmpty) {
      addressError = "Address can't be empty";
      saveLoading = false;
      setState(() {});
      return;
    }
    final contacts = widget.contacts.where((c) => c.address == contactAddress);
    if (contacts.isNotEmpty) {
      addressError = 'Address exists';
      saveLoading = false;
      setState(() {});
      return;
    }
    // TODO: add address validation based on the chain type
    try {
      await addContact(contactName, contactAddress, widget.chainType);
      await _showDialog(
          'Contact Added!',
          'Contact $contactName has been added successfully',
          Icons.check,
          DialogType.Info);
    } catch (e) {
      print(e);
      _showDialog('Error', 'Failed to save contact. Please try again.',
          Icons.error, DialogType.Error);
      saveLoading = false;
      setState(() {});
      return;
    }
    widget.onAddContact(PkidContact(
        name: contactName, address: contactAddress, type: widget.chainType));
    saveLoading = false;
    setState(() {});
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
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
                    label: const Text('Address'),
                    errorText: addressError,
                  ),
                  controller: _addressController,
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
