import 'package:flutter/material.dart';

import '../../../core/styles/color.styles.dart';

Widget labelSeedPhrase = Container(
    child: Text(
  'Enter your existing 24 worded mnemonic seed',
  textAlign: TextAlign.left,
  style: TextStyle(fontWeight: FontWeight.bold),
));

Widget recoverButton(Function cb) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: kThreeFoldGreenColor, padding: EdgeInsets.all(12)),
    onPressed: () => cb(),
    child: Text('RECOVER'),
  );
}

Widget errorText(String? error) {
  if (error == null) return Container();

  return Container(
      padding: EdgeInsets.only(top: 8),
      child: Text(error, style: TextStyle(color: kErrorColor, fontWeight: FontWeight.bold)));
}
