import 'package:flutter/material.dart';

class ReusableTextStep extends StatelessWidget {
  ReusableTextStep({required this.titleText, required this.extraText, required this.errorStepperText});

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
        Divider(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.5),
          child: Container(
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    extraText,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                errorStepperText,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        Divider(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const <Widget>[],
        )
      ],
    );
  }
}

class ReusableTextFieldStep extends StatelessWidget {
  ReusableTextFieldStep(
      {required this.titleText,
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Divider(
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
              suffixStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            controller: controller,
          ),
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                errorStepperText,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        Divider(
          height: 50,
        ),
      ],
    );
  }
}
