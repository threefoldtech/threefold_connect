import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/router.dart';

import '../main.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int, BuildContext) onItemTapped;

  BottomNavBar({GlobalKey key, this.onItemTapped})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final Color backgroundColor = HexColor("#2d4052");

  void _onItemTapped(int index) {
    widget.onItemTapped(index, context);
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return BottomNavigationBar(
    //   type: BottomNavigationBarType.fixed,
    //   backgroundColor: Theme.of(context).primaryColor,
    //   currentIndex: selectedIndex,
    //   selectedItemColor: Colors.white,
    //   unselectedItemColor: Colors.white.withAlpha(100),
    //   onTap: _onItemTapped,
    //   items: Router().getIconButtons(),
    // );
  }
}
