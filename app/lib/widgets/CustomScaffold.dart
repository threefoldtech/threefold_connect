import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/BottomNavbar.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;
  final Widget appBar;

  CustomScaffold({Key key, @required this.body, this.appBar})
      : super(key: key);

  @override
  _CustomScaffoldState createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: SafeArea(
        child: widget.body,
      ),
      // bottomNavigationBar: BottomNavBar(
      //   onItemTapped: changeView,
      // ),
    );
  }

  void changeView(int newId, BuildContext context) {
    Navigator.pushNamed(context, apps[newId]);
  }
}
