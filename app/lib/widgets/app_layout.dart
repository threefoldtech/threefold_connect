import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/constants/navigation_config.dart';

/// Main app layout wrapper that handles navigation, drawer, app bar, and bottom navigation
/// This replaces the layout logic that was previously in HomeScreen
class AppLayout extends StatefulWidget {
  const AppLayout({
    super.key,
    required this.child,
    this.showAppBar = true,
    this.showDrawer = true,
    this.showBottomNav = true,
    this.appBarActions,
    this.title,
    this.onAddFarm,
    this.onAddWallet,
  });

  final Widget child;
  final bool showAppBar;
  final bool showDrawer;
  final bool showBottomNav;
  final List<Widget>? appBarActions;
  final String? title;
  final VoidCallback? onAddFarm;
  final VoidCallback? onAddWallet;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  Globals globals = Globals();

  /// Get current page title based on tab index
  String _getCurrentPageTitle() {
    if (widget.title != null) return widget.title!;

    // Index 0 is now the home page (handled directly in HomeScreen)
    if (globals.tabController.index == 0) {
      return 'Home';
    }
    // Other indices are offset by 1 since we removed home from router
    int routerIndex = globals.tabController.index - 1;
    if (routerIndex >= 0 && routerIndex < Globals().router.routes.length) {
      return Globals().router.routes[routerIndex].route.name;
    }
    return 'Home';
  }

  /// Get current app bar actions based on tab index
  List<Widget>? _getCurrentAppBarActions() {
    if (widget.appBarActions != null) return widget.appBarActions;

    int currentTabIndex = globals.tabController.index;

    // Return app bar actions based on current tab
    final currentEntry = NavigationConfig.getEntryByIndex(currentTabIndex);
    if (currentEntry != null) {
      switch (currentEntry.path) {
        case '/farming': // Farming screen
          return widget.onAddFarm != null
              ? [
                  IconButton(
                    onPressed: widget.onAddFarm,
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Farm',
                  )
                ]
              : null;
        case '/wallet': // Wallet screen
          return widget.onAddWallet != null
              ? [
                  IconButton(
                    onPressed: widget.onAddWallet,
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Wallet',
                  )
                ]
              : null;
        default:
          return null;
      }
    }
    return null;
  }

  /// Get current bottom navigation index
  int _getCurrentBottomNavIndex() {
    return NavigationConfig.getBottomNavIndex(globals.tabController.index);
  }

  /// Handle bottom navigation tap
  void _selectScreen(index) {
    int tabIndex = NavigationConfig.getTabIndexFromBottomNav(index);
    globals.tabController.animateTo(tabIndex);
  }

  /// Build the navigation drawer
  Widget _buildDrawer() {
    return Drawer(
      elevation: 5,
      width: MediaQuery.of(context).size.width * 2 / 3,
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              child: SvgPicture.asset(
                'assets/TF_log_horizontal.svg',
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
              ),
            ),
          ),
          _buildDrawerItem(Icons.home, 'Home', 0),
          _buildDrawerItem(Icons.account_balance_wallet, 'Wallet', NavigationConfig.getEntryByPath('/wallet')!.index),
          if (Globals().canSeeFarmers)
            _buildDrawerItem(Icons.storage, 'Farming', NavigationConfig.getEntryByPath('/farming')!.index)
          else
            Container(),
          _buildDrawerItem(Icons.show_chart_sharp, 'Market', NavigationConfig.getEntryByPath('/market')!.index),
          _buildDrawerItem(Icons.how_to_vote_outlined, 'Dao', NavigationConfig.getEntryByPath('/dao')!.index),
          _buildDrawerItem(Icons.draw_sharp, 'Sign', NavigationConfig.getEntryByPath('/sign')!.index),
          _buildDrawerItem(Icons.article, 'News', NavigationConfig.getEntryByPath('/news')!.index),
          _buildDrawerItem(Icons.settings, 'Settings', NavigationConfig.getEntryByPath('/settings')!.index),
          if (Globals().council)
            _buildDrawerItem(Icons.how_to_vote_outlined, 'Council', NavigationConfig.getEntryByPath('/council')!.index),
        ],
      ),
    );
  }

  /// Build individual drawer item
  Widget _buildDrawerItem(IconData icon, String title, int tabIndex) {
    return ListTile(
      minLeadingWidth: 10,
      leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(icon, size: 18)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        globals.tabController.animateTo(tabIndex);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentTitle = _getCurrentPageTitle();
    int currentBottomNavIndex = _getCurrentBottomNavIndex();

    IconThemeData? selectedIconTheme =
        BottomNavigationBarTheme.of(context).selectedIconTheme;
    Color? selectedItemColor =
        BottomNavigationBarTheme.of(context).selectedItemColor;
    double selectedFontSize = 14;

    if (currentTitle != 'Home' &&
        currentTitle != 'Wallet' &&
        currentTitle != 'Farming' &&
        currentTitle != 'Settings') {
      selectedIconTheme =
          BottomNavigationBarTheme.of(context).unselectedIconTheme;
      selectedItemColor =
          BottomNavigationBarTheme.of(context).unselectedItemColor;
      selectedFontSize = 12;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: widget.showAppBar
            ? AppBar(
                actions: _getCurrentAppBarActions() ?? [],
                title: Text(currentTitle),
                toolbarHeight: 60,
              )
            : null,
        drawer: widget.showDrawer ? _buildDrawer() : null,
        body: widget.child,
        bottomNavigationBar: widget.showBottomNav
            ? BottomNavigationBar(
                onTap: _selectScreen,
                selectedIconTheme: selectedIconTheme,
                selectedItemColor: selectedItemColor,
                showUnselectedLabels: true,
                selectedFontSize: selectedFontSize,
                unselectedFontSize: 12,
                currentIndex: currentBottomNavIndex,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance_wallet),
                      label: 'Wallet'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.storage), label: 'Farming'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings), label: 'Settings'),
                ],
              )
            : null,
      ),
    );
  }
}
