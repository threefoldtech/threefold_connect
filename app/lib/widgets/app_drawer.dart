import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:threebotlogin/helpers/globals.dart';

class DrawerItemData {
  final IconData icon;
  final String label;
  final int tabIndex;

  const DrawerItemData({
    required this.icon,
    required this.label,
    required this.tabIndex,
  });
}

class AppDrawer extends StatelessWidget {
  final ValueChanged<int> onItemSelected;
  final Globals globals = Globals();

  AppDrawer({
    super.key,
    required this.onItemSelected,
  });

  final List<DrawerItemData> _allDrawerItems = const [
    DrawerItemData(icon: Icons.home, label: 'Home', tabIndex: 0),
    DrawerItemData(icon: Icons.article, label: 'News', tabIndex: 1),
    DrawerItemData(
        icon: Icons.account_balance_wallet, label: 'Wallet', tabIndex: 2),
    DrawerItemData(
        icon: Icons.storage, label: 'Farming', tabIndex: 3),
    DrawerItemData(icon: Icons.how_to_vote_outlined, label: 'Dao', tabIndex: 4),
    DrawerItemData(icon: Icons.person, label: 'Identity', tabIndex: 5),
    DrawerItemData(icon: Icons.settings, label: 'Settings', tabIndex: 6),
    DrawerItemData(
        icon: Icons.how_to_vote_outlined, label: 'Council', tabIndex: 7),
  ];

  @override
  Widget build(BuildContext context) {
    final List<DrawerItemData> visibleDrawerItems = [
      _allDrawerItems[0],
      _allDrawerItems[1],
      _allDrawerItems[2],
      if (globals.canSeeFarmers) _allDrawerItems[3],
      _allDrawerItems[4],
      _allDrawerItems[5],
      _allDrawerItems[6],
      if (globals.council) _allDrawerItems[7],
    ];

    return Drawer(
      elevation: 5,
      width: MediaQuery.of(context).size.width * 2 / 3,
      child: Column(
        children: [
          SizedBox(
            height: 110,
            child: DrawerHeader(
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/TF_log_horizontal.svg',
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          ...visibleDrawerItems.map(
            (item) => ListTile(
              minLeadingWidth: 10,
              leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(item.icon, size: 18)),
              title: Text(item.label),
              onTap: () {
                Navigator.pop(context);
                onItemSelected(item.tabIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}
