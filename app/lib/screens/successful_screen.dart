import 'package:flutter/material.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/pop_all_login_event.dart';

class SuccessfulScreen extends StatefulWidget {
  final String title;
  final String text;

  SuccessfulScreen({required this.title, required this.text});

  _SuccessfulScreenState createState() => _SuccessfulScreenState();
}

class _SuccessfulScreenState extends State<SuccessfulScreen> {
  _SuccessfulScreenState() {
    Events().onEvent(PopAllLoginEvent("").runtimeType, close);
  }

  close(PopAllLoginEvent e) {
    if (mounted) {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: new Text("Recovered"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 24.0, bottom: 38.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: 42.0,
                color: Theme.of(context).accentColor,
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                widget.text,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 60.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
