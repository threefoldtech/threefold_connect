import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/helpers/HexColor.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int, BuildContext) onItemTapped;

  BottomNavBar({GlobalKey key, this.selectedIndex, this.onItemTapped})
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
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).primaryColor,
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withAlpha(100),
      onTap: _onItemTapped,
      items: [
        new BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('3Bot'),
        ),
        new BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          title: Text('Pay'),
        ),
        new BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          title: Text('Bla'),
        ),
        new BottomNavigationBarItem(
            icon: Icon(Icons.people), title: Text('Social')),
        new BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), title: Text('ChatBot'))
      ],
    );
  }
}
