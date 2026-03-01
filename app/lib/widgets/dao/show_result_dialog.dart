import 'package:flutter/material.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

enum ProposalType {
  DAO,
  Council,
}

class ShowResultDialog extends StatefulWidget {
  final String proposalHash;
  final ProposalType type;
  final chainUrl;
  const ShowResultDialog({
    super.key,
    required this.proposalHash,
    this.type = ProposalType.DAO,
    this.chainUrl = '',
  });

  @override
  State<ShowResultDialog> createState() => _ShowResultDialogState();
}

class _ShowResultDialogState extends State<ShowResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _noAnimation;
  late Animation<double> _yesAnimation;
  late Animation<double> _animation;

  bool loading = true;
  int totalVotes = 0;
  int noVotesPercentage = 0;
  int yesVotesPercentage = 0;
  int threshold = 1;
  void getVotes() async {
    setState(() {
      loading = true;
    });
    late dynamic votes;
    if (widget.type == ProposalType.DAO) {
      votes = await getProposalVotes(widget.proposalHash);
      totalVotes = votes.ayes.length + votes.nays.length;
      noVotesPercentage =
          await getProposalProgress(votes.ayes, votes.nays, false);
      yesVotesPercentage =
          await getProposalProgress(votes.ayes, votes.nays, true);
    } else {
      votes =
          await getCouncilProposalVotes(widget.chainUrl, widget.proposalHash);
      totalVotes = votes.ayes.length + votes.nays.length;
      final noVotes = votes.nays.length;
      final yesVotes = votes.ayes.length;
      noVotesPercentage = (noVotes / totalVotes * 100).round();
      yesVotesPercentage = (yesVotes / totalVotes * 100).round();
    }
    threshold = votes.threshold;
    setState(() {
      loading = false;
    });
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _noAnimation = Tween<double>(
      begin: 0.0,
      end: totalVotes != 0 ? (noVotesPercentage / 100 * 1.0) : 0,
    ).animate(_animationController);

    _yesAnimation = Tween<double>(
      begin: 0.0,
      end: totalVotes != 0 ? (yesVotesPercentage / 100 * 1.0) : 0,
    ).animate(_animationController);

    _animation = Tween<double>(
      begin: 0.0,
      end: (totalVotes / threshold),
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void initState() {
    super.initState();
    getVotes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              'Loading Votes...',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    minHeight: 40,
                    value: _animation.value,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  );
                },
              ),
              Center(
                child: Text(
                  'Threshold $totalVotes / $threshold',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Yes',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
              Text(totalVotes == 0 ? '0%' : '$yesVotesPercentage%',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
            ],
          ),
          const SizedBox(height: 5),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _yesAnimation.value,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('No',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
              Text(totalVotes == 0 ? '0%' : '$noVotesPercentage%',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
            ],
          ),
          const SizedBox(height: 5),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _noAnimation.value,
                color: Theme.of(context).colorScheme.error,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
              );
            },
          ),
        ]),
      );
    }

    return CustomDialog(
      title: 'Voting Result',
      widgetDescription: content,
      image: Icons.how_to_vote_outlined,
    );
  }
}
