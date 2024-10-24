import 'package:flutter/material.dart';

class ReuseableTextStep extends StatelessWidget {
  const ReuseableTextStep(
      {super.key,
      required this.titleText,
      required this.extraText,
      required this.errorStepperText});

  final String titleText;
  final String extraText;
  final String errorStepperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          titleText,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
        const Divider(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.5),
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  extraText,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                errorStepperText,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        const Divider(
          height: 5,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[],
        )
      ],
    );
  }
}
