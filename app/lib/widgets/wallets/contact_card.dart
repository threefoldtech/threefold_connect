import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/services/contact_service.dart';
import 'package:threebotlogin/widgets/wallets/warning_dialog.dart';

class ContactCardWidget extends StatefulWidget {
  const ContactCardWidget({
    super.key,
    required this.name,
    required this.address,
    required this.canEditAndDelete,
    this.onDeleteContact,
    this.onEditContact,
  });
  final String name;
  final String address;
  final bool canEditAndDelete;
  final void Function(String name)? onDeleteContact;
  final void Function(String oldName, String oldAddress)? onEditContact;

  @override
  State<ContactCardWidget> createState() => _ContactCardWidgetState();
}

class _ContactCardWidgetState extends State<ContactCardWidget> {
  Future<bool> _deleteContact() async {
    try {
      await deleteContact(widget.name);
      widget.onDeleteContact!(widget.name);
      return true;
    } catch (e) {
      logger.e('Failed to delete contact due to $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to delete',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    }
    return false;
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => WarningDialogWidget(
        title: 'Are you sure?',
        description:
            'If you confirm, your contact will be removed from this device.',
        onAgree: _deleteContact,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Theme.of(context).colorScheme.primary)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                  ),
                ),
                if (widget.canEditAndDelete)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            widget.onEditContact!(widget.name, widget.address);
                          },
                          icon: const Icon(
                            Icons.edit,
                          )),
                      IconButton(
                          onPressed: _showDeleteConfirmationDialog,
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          )),
                    ],
                  ),
              ],
            ),
            Text(
              widget.address,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
