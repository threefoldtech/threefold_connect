import 'package:flutter/material.dart';
import 'package:threebotlogin/services/contact_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

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
  bool deleteLoading = false;
  _deleteWallet() async {
    setState(() {
      deleteLoading = true;
    });
    //TODO: Show snack in case of failure
    await deleteContact(widget.name);
    widget.onDeleteContact!(widget.name);

    setState(() {
      deleteLoading = false;
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: DialogType.Warning,
        image: Icons.warning,
        title: 'Are you sure?',
        description:
            'If you confirm, your wallet will be removed from this device.',
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            onPressed: () async {
              await _deleteWallet();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            //TODO: show loading when press yes
            child: Text(
              'Yes',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Theme.of(context).colorScheme.background,
      // shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(5),
      //     side: BorderSide(color: Theme.of(context).colorScheme.primary)),
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
                      deleteLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.error,
                              ))
                          : IconButton(
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
