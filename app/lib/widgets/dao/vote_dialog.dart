import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gridproxy_client/models/farms.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;

class VoteDialog extends ConsumerStatefulWidget {
  final String proposalHash;
  const VoteDialog({
    required this.proposalHash,
    super.key,
  });

  @override
  ConsumerState<VoteDialog> createState() => _VoteDialogState();
}

class _VoteDialogState extends ConsumerState<VoteDialog> {
  int? farmId;
  List<Farm> farms = [];
  Map<int, Wallet> twinIdWallets = {};
  bool loading = true;
  bool yesLoading = false;
  bool noLoading = false;

  void getFarms() async {
    try {
      setState(() {
        loading = true;
      });
      await ref.read(walletsNotifier.notifier).list();
      final wallets = ref.read(walletsNotifier);
      final twinIdFutures = wallets.map((w) async {
        final twinId = await TFChainService.getTwinId(w.tfchainSecret);
        if (twinId != 0) {
          twinIdWallets[twinId] = w;
        }
      }).toList();

      await Future.wait(twinIdFutures);

      farms =
          await getFarmsByTwinIds(twinIdWallets.keys.toList(), hasUpNode: true);
    } catch (e) {
      throw Exception('Failed to get farms due to $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFarms();
  }

  List<DropdownMenuEntry<int>> _buildDropdownMenuEntries(List<Farm> farms) {
    return farms.map((farm) {
      return DropdownMenuEntry<int>(
        value: farm.farmID,
        label: farm.name,
        labelWidget: Text(farm.name,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      if (farms.isEmpty) {
        content = Text(
          'No farms available with online node to vote.',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          textAlign: TextAlign.center,
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
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                label: Text(
                  'Select Farm',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
                dropdownMenuEntries: _buildDropdownMenuEntries(farms),
                onSelected: (int? value) {
                  if (value != null) {
                    farmId = value;
                  }
                },
              ),
            ],
          ),
        );
      }
    }
    return CustomDialog(
      title: 'Vote',
      widgetDescription: content,
      image: Icons.how_to_vote_outlined,
      actions: farms.isEmpty && !loading
          ? <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ]
          : loading
              ? null
              : <Widget>[
                  TextButton(
                    child: noLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('No'),
                    onPressed: () {
                      _vote(false);
                    },
                  ),
                  TextButton(
                    child: yesLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Yes',
                          ),
                    onPressed: () async {
                      _vote(true);
                    },
                  )
                ],
    );
  }

  void _vote(bool approve) async {
    if (yesLoading || noLoading || farmId == null) return;
    setState(() {
      approve ? (yesLoading = true) : (noLoading = true);
    });
    final farm = farms.firstWhere((farm) => farm.farmID == farmId);
    final twinId = farm.twinId;
    final seed = twinIdWallets[twinId]!.tfchainSecret;
    final votes = await getProposalVotes(widget.proposalHash);

    final hasVotedYes = votes.ayes.any((vote) => vote.farmId == farmId);
    final hasVotedNo = votes.nays.any((vote) => vote.farmId == farmId);

    if ((approve && hasVotedYes) || (!approve && hasVotedNo)) {
      await _showDialog('Voted!', 'You have voted successfully.', Icons.check,
          DialogType.Info);
      Navigator.of(context).pop();
      setState(() {
        yesLoading = false;
        noLoading = false;
      });
      return;
    }
    try {
      await vote(approve, widget.proposalHash, farmId!, seed);
      await _showDialog('Voted!', 'You have voted successfully.', Icons.check,
          DialogType.Info);
      Navigator.of(context).pop();
    } catch (e) {
      _showDialog('Error', 'Failed to Vote.', Icons.error, DialogType.Error);
    } finally {
      setState(() {
        yesLoading = false;
        noLoading = false;
      });
    }
  }

  Future<void> _showDialog(
      String title, String description, IconData icon, DialogType type) async {
    if (context.mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CustomDialog(
          type: type,
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
