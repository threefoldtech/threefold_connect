import 'package:flutter/material.dart';
import 'package:tfchain_client/models/dao.dart';
import 'package:url_launcher/url_launcher.dart';
import 'show_result_dialog.dart';
import 'vote_dialog.dart';

class DaoCard extends StatefulWidget {
  final Proposal proposal;
  final bool active;

  const DaoCard({
    required this.proposal,
    required this.active,
    super.key,
  });

  @override
  State<DaoCard> createState() => _DaoCardState();
}

class _DaoCardState extends State<DaoCard> {
  Future<void> _launchUrl() async {
    if (widget.proposal.link != "") {
      final Uri url = Uri.parse(widget.proposal.link);
      if (!await launchUrl(url)) {
        const SnackBar(
          content: Text(
              "Can't go to proposal at this moment please try again later"),
        );
      }
    }
  }

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
                widget.proposal.action,
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
              child: Text(
                widget.proposal.description,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton(
                onPressed: _launchUrl,
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Go to proposal',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
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
              mainAxisAlignment: widget.active
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
                if (widget.active)
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
            ));
  }

  _showVoteDialog() {
    showDialog(
        context: context,
        builder: (_) => VoteDialog(
              proposalHash: widget.proposal.hash,
            ));
  }
}
