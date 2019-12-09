import 'package:flutter/material.dart';

class Toolbar extends StatefulWidget {
  final Widget pinField;
  final String title;
  Toolbar(this.title, {Key key, this.pinField}) : super(key: key);
  _Toolbar createState() => _Toolbar();
}

class _Toolbar extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      elevation: 0.0,
    );
  }
}
