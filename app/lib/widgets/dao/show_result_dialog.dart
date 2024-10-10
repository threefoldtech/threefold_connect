import 'package:flutter/material.dart';
import 'package:threebotlogin/services/tfchain_service.dart';

class ShowResultDialog extends StatefulWidget {
  final String proposalHash;
  const ShowResultDialog({
    required this.proposalHash,
    super.key,
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
  int noVotes = 0;
  int yesVotes = 0;
  int threshold = 1;
  void getVotes() async {
    setState(() {
      loading = true;
    });
    final votes = await getProposalVotes(widget.proposalHash);
    totalVotes = votes.ayes.length + votes.nays.length;
    noVotes = votes.nays.length;
    yesVotes = votes.ayes.length;
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
      end: totalVotes != 0 ? (noVotes / totalVotes * 1.0) : 0,
    ).animate(_animationController);

    _yesAnimation = Tween<double>(
      begin: 0.0,
      end: totalVotes != 0 ? (yesVotes / totalVotes * 1.0) : 0,
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
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
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
              Text(
                  totalVotes == 0
                      ? '0%'
                      : '${((yesVotes / totalVotes) * 100).toStringAsFixed(0)}%',
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
              Text(
                  totalVotes == 0
                      ? '0%'
                      : '${(noVotes / totalVotes * 100).toStringAsFixed(0)}%',
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
              );
            },
          ),
        ]),
      );
    }

    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: content);
  }
}
