import 'package:flutter/material.dart';

Widget introText = RichText(
  textAlign: TextAlign.center,
  text: new TextSpan(
      style: new TextStyle(
        fontSize: 18.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        new TextSpan(text: 'Welcome to the\n'),
        new TextSpan(text: 'ThreeFold Connect App! \n', style: new TextStyle(fontWeight: FontWeight.bold)),
        new TextSpan(text: 'Click on the '),
        new TextSpan(text: 'menu ', style: new TextStyle(fontWeight: FontWeight.bold)),
        new TextSpan(text: 'icon \n to get started'),
      ]),
);
