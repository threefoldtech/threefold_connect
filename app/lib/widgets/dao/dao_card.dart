import 'package:flutter/material.dart';
import 'package:tfchain_client/models/dao.dart';
import 'package:threebotlogin/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'show_result_dialog.dart';
import 'vote_dialog.dart';

class DaoCard extends StatefulWidget {
  final Proposal proposal;

  const DaoCard({
    required this.proposal,
    super.key,
  });

  @override
  State<DaoCard> createState() => _DaoCardState();
}

class _DaoCardState extends State<DaoCard> {
  @override
  void initState() {
    super.initState();
  }

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
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.backgroundDarker,
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
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
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: TextButton(
                  onPressed: () async {
                    final votes = await getProposalVotes(widget.proposal.hash);
                    // ignore: use_build_context_synchronously
                    showDialog(
                        context: context,
                        builder: (_) => ShowResultDialog(
                              totalVotes: votes.ayes.length + votes.nays.length,
                              noVotes: votes.nays.length,
                              yesVotes: votes.ayes.length,
                              threshold: votes.threshold,
                            ));
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Show result',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => VoteDialog(
                            proposal: widget.proposal,
                          ));
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Vote',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
