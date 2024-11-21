import 'package:flutter/material.dart';

Widget getErrorWidget(BuildContext context, FlutterErrorDetails error) {
  // logger.i(Theme.of(context).textTheme);
  return const SafeArea(
    child: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Oops something went wrong.',
                  style: TextStyle(color: Colors.red)),
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
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
