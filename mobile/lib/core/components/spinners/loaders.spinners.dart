import 'package:flutter/material.dart';

Widget kLoadingSpinnerXs = Transform.scale(
  scale: 0.5,
  child: CircularProgressIndicator(
    color: Color.fromRGBO(0, 174, 239, 1),
  ),
);

Widget kLoadingSpinnerMd = Transform.scale(
  scale: 0.75,
  child: CircularProgressIndicator(
    color: Color.fromRGBO(0, 174, 239, 1),
  ),
);

Widget kLoadingSpinnerLg = Transform.scale(
  scale: 1,
  child: CircularProgressIndicator(
    color: Color.fromRGBO(0, 174, 239, 1),
  ),
);
