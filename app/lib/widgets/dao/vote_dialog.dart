import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gridproxy_client/models/farms.dart';

import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class VoteDialog extends StatefulWidget {
  final String proposalHash;
  const VoteDialog({
    required this.proposalHash,
    super.key,
  });

  @override
  State<VoteDialog> createState() => _VoteDialogState();
}

class _VoteDialogState extends State<VoteDialog> {
  int? farmId;
  final List<Farm> farms = [];
  Map<int, String> twinIdWallets = {};
  bool loading = true;
  bool yesLoading = false;
  bool noLoading = false;

  void getFarms() async {
    setState(() {
      loading = true;
    });
    twinIdWallets = await getWalletsTwinIds();
    List<Farm> farmsList = await getFarmsByTwinIds(twinIdWallets.keys.toList());
    farms.addAll(farmsList);
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    getFarms();
    super.initState();
  }

  List<DropdownMenuEntry<int>> _buildDropdownMenuEntries(List<Farm> farms) {
    return farms.map((farm) {
      return DropdownMenuEntry<int>(
        value: farm.farmID,
        label: farm.name,
        labelWidget: Text(farm.name,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                )),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 15),
            Text(
              'Loading Farms...',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.all(30),
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownMenu(
              menuHeight: MediaQuery.sizeOf(context).height * 0.3,
              enableFilter: true,
              width: MediaQuery.sizeOf(context).width * 0.55,
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
                'Select Farm',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              dropdownMenuEntries: _buildDropdownMenuEntries(farms),
              onSelected: (int? value) {
                if (value != null) {
                  farmId = value;
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _vote(true);
                  },
                  child: yesLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ))
                      : Text(
                          'Yes',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _vote(false);
                  },
                  child: noLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ))
                      : Text(
                          'No',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: content);
  }

  void _vote(bool approve) async {
    if (yesLoading || noLoading || farmId == null) return;
    setState(() {
      approve ? (yesLoading = true) : (noLoading = true);
    });
    final farm = farms.firstWhere((farm) => farm.farmID == farmId);
    final twinId = farm.twinId;
    final seed = twinIdWallets[twinId];
    try {
      await vote(approve, widget.proposalHash, farmId!, seed!);

      _showDialog('Vote', 'You have voted successfully.', Icons.check);
    } catch (e) {
      _showDialog('Vote', 'Failed to Vote.', Icons.error);
    } finally {
      setState(() {
        yesLoading = false;
        noLoading = false;
      });
    }
  }

  _showDialog(String title, String description, IconData icon) async {
    if (context.mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog(
          image: icon,
          title: title,
          description: description,
        ),
      );
      await Future.delayed(
        const Duration(seconds: 3),
        () {
          Navigator.pop(context);
        },
      );
    }
  }
}
