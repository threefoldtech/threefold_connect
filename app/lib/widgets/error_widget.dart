import 'package:flutter/material.dart';

Widget getErrorWidget(BuildContext context, FlutterErrorDetails error) {
  return SafeArea(
    child: Scaffold(
      backgroundColor: Color(0xff0f296a),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Oops something went wrong.",
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
