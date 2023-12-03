import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/hex_color.dart';

Widget getErrorWidget(BuildContext context, FlutterErrorDetails error) {
  return SafeArea(
    child: Scaffold(
      backgroundColor: HexColor('#0f296a'),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Oops something went wrong.',
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Please restart the application. If this error persists, please contact support.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
