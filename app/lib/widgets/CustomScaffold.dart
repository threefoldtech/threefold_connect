import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/BottomNavbar.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final int selectedApp;
  final Widget appBar;
  final GlobalKey<BottomNavBarState> navbarKey;

  const CustomScaffold(
      {Key key,
      @required this.body,
      this.selectedApp = 0,
      this.appBar,
      this.navbarKey})
      : super(key: key);

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: BottomNavBar(
        key: navbarKey,
        selectedIndex: selectedApp,
        onItemTapped: changeView,
      ),
    );
  }

  void changeView(int newId, BuildContext context) {
    print('Opening $newId : ' + apps[newId]);
    Navigator.pushNamed(context, apps[newId]);
  }
}
