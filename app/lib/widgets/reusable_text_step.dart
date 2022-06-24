import 'package:flutter/material.dart';

class ReuseableTextStep extends StatelessWidget {
  ReuseableTextStep(
      {required this.titleText,
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
          children: const <Widget>[
          ],
        )
      ],
    );
  }
}
