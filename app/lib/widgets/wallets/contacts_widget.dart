import 'package:flutter/material.dart';
import 'package:threebotlogin/models/contact.dart';
import 'package:threebotlogin/widgets/wallets/contact_card.dart';

class ContactsWidget extends StatelessWidget {
  const ContactsWidget({
    super.key,
    required this.contacts,
    required this.onSelectToAddress,
  });
  final List<PkidContact> contacts;
  final void Function(String address) onSelectToAddress;

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      for (final contact in contacts)
        InkWell(
            onTap: () {
              onSelectToAddress(contact.address);
              Navigator.of(context).pop();
            },
            child: ContactCardWidget(
              name: contact.name,
              address: contact.address,
            )),
    ]);
  }
}
