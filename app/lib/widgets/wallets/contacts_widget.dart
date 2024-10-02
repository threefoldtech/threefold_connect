import 'package:flutter/material.dart';
import 'package:threebotlogin/models/contact.dart';
import 'package:threebotlogin/widgets/wallets/contact_card.dart';

class ContactsWidget extends StatelessWidget {
  const ContactsWidget({
    super.key,
    required this.contacts,
    required this.onSelectToAddress,
    this.onDeleteContact,
    this.onEditContact,
    this.canEditAndDelete = false,
  });

  final List<PkidContact> contacts;
  final void Function(String address) onSelectToAddress;
  final bool canEditAndDelete;
  final void Function(String name)? onDeleteContact;
  final void Function(String oldName, String oldAddress)? onEditContact;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (contacts.isEmpty) {
      content = Center(
        child: Text(
          'No contacts yet.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onBackground),
        ),
      );
    } else {
      content = ListView(children: [
        for (final contact in contacts)
          InkWell(
              onTap: () {
                onSelectToAddress(contact.address);
                Navigator.of(context).pop();
              },
              child: ContactCardWidget(
                name: contact.name,
                address: contact.address,
                canEditAndDelete: canEditAndDelete,
                onDeleteContact: onDeleteContact,
                onEditContact: onEditContact,
              )),
      ]);
    }
    return content;
  }
}
