import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/contact.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/contact_service.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class AddEditContact extends StatefulWidget {
  const AddEditContact({
    super.key,
    required this.contacts,
    required this.chainType,
    this.operation = ContactOperation.Add,
    this.onAddContact,
    this.name = '',
    this.address = '',
    this.onEditContact,
  });

  final void Function(PkidContact addedContact)? onAddContact;
  final List<PkidContact> contacts;
  final ChainType chainType;
  final ContactOperation operation;
  final String name;
  final String address;
  final void Function(String oldName, String newName, String newAddress)?
      onEditContact;

  @override
  State<StatefulWidget> createState() {
    return _AddEditContactState();
  }
}

class _AddEditContactState extends State<AddEditContact> {
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

  bool _validateName(String contactName, {bool edit = false}) {
    nameError = null;

    if (contactName.isEmpty) {
      nameError = "Name can't be empty";
      return false;
    }
    final c = widget.contacts.where((c) => c.name == contactName);
    if (edit && contactName != widget.name && c.isNotEmpty) {
      nameError = 'Name is used for another contact';
      return false;
    } else if (!edit && c.isNotEmpty) {
      nameError = 'Name exists';
      return false;
    }
    return true;
  }

  bool _validateAddress(String contactAddress, {bool edit = false}) {
    addressError = null;

    if (contactAddress.isEmpty) {
      addressError = "Address can't be empty";
      return false;
    }
    final contacts = widget.contacts.where((c) => c.address == contactAddress);
    if (edit && contactAddress != widget.address && contacts.isNotEmpty) {
      addressError = 'Address is used in another contact';
      return false;
    } else if (!edit && contacts.isNotEmpty) {
      addressError = 'Address exists in ${contacts.first.type.name}';
      return false;
    }
    if (widget.chainType == ChainType.TFChain && contactAddress.length != 48) {
      addressError = 'Address length should be 48 characters';
      return false;
    }
    if (widget.chainType == ChainType.Stellar &&
        !isValidStellarAddress(contactAddress)) {
      addressError = 'Invaild Stellar address';
      return false;
    }
    return true;
  }

  _add(String contactName, String contactAddress) async {
    try {
      await addContact(contactName, contactAddress, widget.chainType);
      await _showDialog(
          'Contact Added!',
          'Contact $contactName has been added successfully',
          Icons.check,
          DialogType.Info);
    } catch (e) {
      logger.e(e);
      _showDialog('Error', 'Failed to save contact. Please try again.',
          Icons.error, DialogType.Error);
      return;
    }
    widget.onAddContact!(PkidContact(
        name: contactName, address: contactAddress, type: widget.chainType));
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  _edit(String contactName, String contactAddress) async {
    try {
      await editContact(widget.name, contactName, contactAddress);
      await _showDialog(
          'Contact Modified!',
          'Contact $contactName has been modified successfully',
          Icons.check,
          DialogType.Info);
    } catch (e) {
      logger.e(e);
      _showDialog('Error', 'Failed to modify contact. Please try again.',
          Icons.error, DialogType.Error);
      return;
    }
    widget.onEditContact!(widget.name, contactName, contactAddress);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> _validateAndAdd() async {
    final contactName = _nameController.text.trim();
    final contactAddress = _addressController.text.trim();
    saveLoading = true;
    setState(() {});
    final validName = _validateName(contactName);
    final validAddress = _validateAddress(contactAddress);

    if (validName && validAddress) {
      await _add(contactName, contactAddress);
    }
    saveLoading = false;
    setState(() {});
  }

  Future<void> _validateAndEdit() async {
    final contactName = _nameController.text.trim();
    final contactAddress = _addressController.text.trim();
    saveLoading = true;
    setState(() {});
    final validName = _validateName(contactName, edit: true);
    final validAddress = _validateAddress(contactAddress, edit: true);

    if (validName &&
        validAddress &&
        (contactName != widget.name || contactAddress != widget.address)) {
      await _edit(contactName, contactAddress);
    }
    saveLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    if (widget.operation == ContactOperation.Edit) {
      _nameController.text = widget.name;
      _addressController.text = widget.address;
    }
    super.initState();
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
                Text(
                  widget.operation == ContactOperation.Add
                      ? 'Add Contact'
                      : 'Edit Contact',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      decorationColor: Theme.of(context).colorScheme.onSurface),
                  maxLength: 50,
                  decoration: InputDecoration(
                      label: const Text('Name'), errorText: nameError),
                  controller: _nameController,
                ),
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      decorationColor: Theme.of(context).colorScheme.onSurface),
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
                        onPressed: widget.operation == ContactOperation.Add
                            ? _validateAndAdd
                            : _validateAndEdit,
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
