import 'package:flutter/material.dart';

class ShowResultDialog extends StatefulWidget {
  final int totalVotes;
  final int noVotes;
  final int yesVotes;
  final int threshold;
  const ShowResultDialog({
    required this.threshold,
    required this.noVotes,
    required this.yesVotes,
    required this.totalVotes,
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

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _noAnimation = Tween<double>(
      begin: 0.0,
      end: widget.totalVotes != 0
          ? (widget.noVotes / widget.totalVotes * 1.0)
          : 0,
    ).animate(_animationController);

    _yesAnimation = Tween<double>(
      begin: 0.0,
      end: widget.totalVotes != 0
          ? (widget.yesVotes / widget.totalVotes * 1.0)
          : 0,
    ).animate(_animationController);

    _animation = Tween<double>(
      begin: 0.0,
      end: (widget.totalVotes / widget.threshold),
    ).animate(_animationController);

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Padding(
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
                    // backgroundColor: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  );
                },
              ),
              Center(
                child: Text(
                    'Threshold ${widget.totalVotes} / ${widget.threshold}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Yes',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
              Text(
                  widget.totalVotes == 0
                      ? '0%'
                      : '${(widget.yesVotes / widget.totalVotes) * 100}%',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
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
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
              Text(
                  widget.totalVotes == 0
                      ? '0%'
                      : '${widget.noVotes / widget.totalVotes * 100}%',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
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
      ),
    );
  }
}
