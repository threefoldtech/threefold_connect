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
        ),
        const Divider(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.5),
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  extraText,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
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
                style: const TextStyle(color: Colors.red),
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
