import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/BottomNavbar.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final int selectedApp;
  final Widget appBar;

  const CustomScaffold(
      {Key key,
      @required this.body,
      this.selectedApp = 0,
      this.appBar})
      : super(key: key);

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bla'),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: body,
      ),
      // bottomNavigationBar: BottomNavBar(
      //   selectedIndex: selectedApp,
      //   onItemTapped: changeView,
      // ),
    );
  }

  void changeView(int newId) {}
}
