import 'package:flutter/material.dart';

class BottomNavItemData {
  final IconData icon;
  final String label;
  final int tabIndex;
  const BottomNavItemData({
    required this.icon,
    required this.label,
    required this.tabIndex,
  });
}

class AppBottomNavigationBar extends StatelessWidget {
  final int currentTabIndex;
  final ValueChanged<int> onItemSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.currentTabIndex,
    required this.onItemSelected,
  });

  final List<BottomNavItemData> _bottomNavItems = const [
    BottomNavItemData(icon: Icons.home, label: 'Home', tabIndex: 0),
    BottomNavItemData(
        icon: Icons.account_balance_wallet, label: 'Wallet', tabIndex: 2),
    BottomNavItemData(icon: Icons.storage, label: 'Farming', tabIndex: 3),
    BottomNavItemData(icon: Icons.settings, label: 'Settings', tabIndex: 6),
  ];

  int _getItemIndex(int tabIndex) {
    for (int i = 0; i < _bottomNavItems.length; i++) {
      if (_bottomNavItems[i].tabIndex == tabIndex) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavTheme = BottomNavigationBarTheme.of(context);

    return BottomNavigationBar(
      onTap: onItemSelected,
      currentIndex: _getItemIndex(currentTabIndex),
      selectedIconTheme: bottomNavTheme.selectedIconTheme,
      unselectedIconTheme: bottomNavTheme.unselectedIconTheme,
      selectedItemColor: bottomNavTheme.selectedItemColor,
      unselectedItemColor: bottomNavTheme.unselectedItemColor,
      showUnselectedLabels: true,
      selectedFontSize: 12.0,
      unselectedFontSize: 12.0,
      type: BottomNavigationBarType.fixed,
      items: _bottomNavItems
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }
}
