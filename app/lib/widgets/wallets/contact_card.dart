import 'package:flutter/material.dart';

class ContactCardWidget extends StatelessWidget {
  const ContactCardWidget(
      {super.key,
      required this.name,
      required this.address,
      required this.canEditAndDelete});
  final String name;
  final String address;
  final bool canEditAndDelete;

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
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                  ),
                ),
                if (canEditAndDelete)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          )),
                    ],
                  ),
              ],
            ),
            Text(
              address,
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
