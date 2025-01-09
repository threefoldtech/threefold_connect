import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
// ignore: depend_on_referenced_packages
import 'package:polkadart_keyring/polkadart_keyring.dart';

class CouncilVoteDialog extends ConsumerStatefulWidget {
  final String proposalHash;
  final String chainUrl;
  const CouncilVoteDialog({
    required this.proposalHash,
    required this.chainUrl,
    super.key,
  });

  @override
  ConsumerState<CouncilVoteDialog> createState() => _CouncilVoteDialogState();
}

class _CouncilVoteDialogState extends ConsumerState<CouncilVoteDialog> {
  bool loading = true;
  bool yesLoading = false;
  bool noLoading = false;
  List<Wallet> wallets = [];
  String walletName = '';

  void getWallets() async {
    try {
      setState(() {
        loading = true;
      });
      await ref.read(walletsNotifier.notifier).list();
      wallets = ref.read(walletsNotifier);
      final members = await getCouncilMembers(widget.chainUrl);
      wallets =
          wallets.where((w) => members.contains(w.tfchainAddress)).toList();
    } catch (e) {
      throw Exception('Failed to get wallets due to $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getWallets();
  }

  List<DropdownMenuEntry<String>> _buildDropdownMenuEntries(
      List<Wallet> wallets) {
    return wallets.map((wallet) {
      return DropdownMenuEntry<String>(
        value: wallet.name,
        label: wallet.name,
        labelWidget: Text(wallet.name,
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
              'Loading Wallets...',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      if (wallets.isEmpty) {
        content = Text(
          'No wallets available to vote.',
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
                  'Select Wallet',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
                dropdownMenuEntries: _buildDropdownMenuEntries(wallets),
                onSelected: (String? value) {
                  if (value != null) {
                    walletName = value;
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
      actions: wallets.isEmpty && !loading
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
    if (yesLoading || noLoading || walletName == '') return;
    setState(() {
      approve ? (yesLoading = true) : (noLoading = true);
    });
    final wallet = wallets.firstWhere((wallet) => wallet.name == walletName);
    final seed = wallet.tfchainSecret;
    final votes =
        await getCouncilProposalVotes(widget.chainUrl, widget.proposalHash);
    final keyring = Keyring();

    final hasVotedYes = votes.ayes
        .any((voter) => keyring.encodeAddress(voter) == wallet.tfchainAddress);
    final hasVotedNo = votes.nays
        .any((voter) => keyring.encodeAddress(voter) == wallet.tfchainAddress);

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
      await councilVote(widget.chainUrl, approve, widget.proposalHash, seed);
      await _showDialog('Voted!', 'You have voted successfully.', Icons.check,
          DialogType.Info);
      Navigator.of(context).pop();
    } catch (e) {
      _showDialog('Error', 'Failed to Vote.', Icons.error, DialogType.Error);
      logger.e(e);
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
