import 'package:flutter/material.dart';
import 'package:tfchain_client/models/council.dart';
import 'package:threebotlogin/widgets/council/vote.dart';
import 'package:threebotlogin/widgets/dao/show_result_dialog.dart';

class CouncilCard extends StatefulWidget {
  const CouncilCard(
      {super.key, required this.proposal, required this.chainUrl});
  final CouncilProposal proposal;
  final String chainUrl;

  @override
  State<CouncilCard> createState() => _CouncilCardState();
}

class _CouncilCardState extends State<CouncilCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                widget.proposal.index.toString(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                textAlign: TextAlign.start,
              ),
            ),
            Divider(
              thickness: 2,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Module: ${widget.proposal.module}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Method: ${widget.proposal.method}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'args: ${widget.proposal.args}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'You can vote until:',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.proposal.end.formatDateTime(),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: widget.proposal.active
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _showVoteResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Text('Show result',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer)),
                ),
                if (widget.proposal.active)
                  ElevatedButton(
                    onPressed: _showVoteDialog,
                    child: Text(
                      'Vote',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _showVoteResult() {
    showDialog(
        context: context,
        builder: (_) => ShowResultDialog(
              proposalHash: widget.proposal.hash,
              type: ProposalType.Council,
              chainUrl: widget.chainUrl,
            ));
  }

  _showVoteDialog() {
    showDialog(
        context: context,
        builder: (_) => CouncilVoteDialog(
              proposalHash: widget.proposal.hash,
              chainUrl: widget.chainUrl,
            ));
  }
}
