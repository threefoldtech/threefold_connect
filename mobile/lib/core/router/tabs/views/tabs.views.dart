import 'package:flutter/material.dart';
import 'package:threebotlogin/core/router/tabs/widgets/tabs.widgets.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';

class LayoutDrawer extends StatefulWidget {
  LayoutDrawer({required this.titleText, required this.content});

  final String titleText;
  final Widget content;

  @override
  _LayoutDrawerState createState() => _LayoutDrawerState();
}

class _LayoutDrawerState extends State<LayoutDrawer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(widget.titleText),
          backgroundColor: kAppBarColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SafeArea(child: widget.content),
        drawer: SafeArea(child: Drawer(child: Column(children: <Widget>[logo, tabs(context)]))));
  }
}
