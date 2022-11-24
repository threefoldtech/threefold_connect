import 'package:flutter/material.dart';

Future<void> showLoadingDialog(BuildContext ctx) {
  return showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (BuildContext context) => Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10,
          ),
          new CircularProgressIndicator(),
          SizedBox(
            height: 10,
          ),
          new Text("Loading"),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    ),
  );
}
