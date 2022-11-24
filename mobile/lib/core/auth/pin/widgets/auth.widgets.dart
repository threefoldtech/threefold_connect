import 'package:flutter/material.dart';

Widget authPins(pins) {
  return Container(
    width: double.infinity,
    child: Center(
      child: Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: pins.take(3).toList()),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: pins.skip(3).take(3).toList()),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: pins.skip(6).take(3).toList()),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: pins.skip(9).take(3).toList()),
        ],
      ),
    ),
  );
}
