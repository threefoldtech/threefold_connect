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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Divider(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.5),
          child: TextFormField(
            focusNode: focusNode,
            autofocus: true,
            keyboardType: typeText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
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
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        const Divider(
          height: 50,
        ),
      ],
    );
  }
}
