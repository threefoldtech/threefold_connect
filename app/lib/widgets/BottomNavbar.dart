import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/helpers/HexColor.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

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
    if (index == 2) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Coming soon"),
      ));
      return;
    }

    widget.onItemTapped(index);
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
          icon: Icon(
            Icons.supervised_user_circle,
            color: Colors.grey.shade700,
          ),
          title: Text(
            'Circles',
            style: new TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
        new BottomNavigationBarItem(
            icon: Icon(Icons.people), title: Text('Social')),
        new BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), title: Text('ChatBot'))
      ],
    );
  }
}
