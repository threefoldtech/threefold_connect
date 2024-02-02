import 'package:flutter/material.dart';

class ReuseableTextFieldStep extends StatelessWidget {
  const ReuseableTextFieldStep(
      {super.key,
      required this.titleText,
      required this.labelText,
      required this.focusNode,
      required this.controller,
      required this.typeText,
      required this.errorStepperText,
      this.suffixText});

  final String titleText;
  final String labelText;
  final String errorStepperText;
  final FocusNode focusNode;
  final TextEditingController controller;
  final String? suffixText;
  final TextInputType typeText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          titleText,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
        Divider(
          height: 40,
          color: Theme.of(context)
              .colorScheme
              .onSecondaryContainer
              .withOpacity(0.2),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.5),
          child: TextFormField(
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                decorationColor:
                    Theme.of(context).colorScheme.onSecondaryContainer),
            focusNode: focusNode,
            autofocus: true,
            keyboardType: typeText,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: labelText,
              suffixText: suffixText,
              suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            controller: controller,
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
      ],
    );
  }
}
