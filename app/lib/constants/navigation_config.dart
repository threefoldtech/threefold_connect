import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/globals.dart';

/// Data class to hold navigation entry information
class NavigationEntry {
  final String name;
  final String path;
  final IconData icon;
  final bool showInBottomNav;
  final bool showInDrawer;
  final int _cachedIndex;

  const NavigationEntry({
    required this.name,
    required this.path,
    required this.icon,
    this.showInBottomNav = false,
    this.showInDrawer = true,
    required int cachedIndex,
  }) : _cachedIndex = cachedIndex;

  int get index => _cachedIndex;
}

class NavigationConfig {
  static final Map<String, NavigationEntry> _pathToEntry = {};
  static final Map<String, NavigationEntry> _nameToEntry = {};
  static final Map<int, NavigationEntry> _indexToEntry = {};
  static List<NavigationEntry>? _bottomNavEntries;
  static List<NavigationEntry>? _drawerEntries;
  static bool _isInitialized = false;

  // Navigation entries configuration
  static const List<NavigationEntry> _navigationEntries = [
    NavigationEntry(
      name: 'Home',
      path: '/home',
      icon: Icons.home,
      showInBottomNav: true,
      showInDrawer: true,
      cachedIndex: 0,
    ),
    NavigationEntry(
      name: 'News',
      path: '/news',
      icon: Icons.article,
      showInDrawer: true,
      cachedIndex: 1,
    ),
    NavigationEntry(
      name: 'Wallet',
      path: '/wallet',
      icon: Icons.account_balance_wallet,
      showInBottomNav: true,
      showInDrawer: true,
      cachedIndex: 2,
    ),
    NavigationEntry(
      name: 'Farming',
      path: '/farming',
      icon: Icons.storage,
      showInBottomNav: true,
      showInDrawer: true,
      cachedIndex: 3,
    ),
    NavigationEntry(
      name: 'Dao',
      path: '/dao',
      icon: Icons.how_to_vote_outlined,
      showInDrawer: true,
      cachedIndex: 4,
    ),
    NavigationEntry(
      name: 'Identity',
      path: '/identity',
      icon: Icons.lock,
      showInDrawer: true,
      cachedIndex: 5,
    ),
    NavigationEntry(
      name: 'Market',
      path: '/market',
      icon: Icons.show_chart_sharp,
      showInDrawer: true,
      cachedIndex: 6,
    ),
    NavigationEntry(
      name: 'Settings',
      path: '/settings',
      icon: Icons.settings,
      showInBottomNav: true,
      showInDrawer: true,
      cachedIndex: 7,
    ),
    NavigationEntry(
      name: 'Council',
      path: '/council',
      icon: Icons.how_to_vote_outlined,
      showInDrawer: true,
      cachedIndex: 8,
    ),
    NavigationEntry(
      name: 'Sign',
      path: '/sign',
      icon: Icons.draw_sharp,
      showInDrawer: true,
      cachedIndex: 9,
    ),
    NavigationEntry(
      name: 'Notifications',
      path: '/notifications',
      icon: Icons.notifications,
      showInDrawer: true,
      cachedIndex: 10,
    ),
  ];

  static void initialize() {
    if (_isInitialized) return;

    // Build cached maps for O(1) lookups
    for (final entry in _navigationEntries) {
      _pathToEntry[entry.path] = entry;
      _nameToEntry[entry.name] = entry;
      _indexToEntry[entry.index] = entry;
    }

    // Cache filtered lists
    _bottomNavEntries = _navigationEntries.where((entry) => entry.showInBottomNav).toList();
    _drawerEntries = _navigationEntries.where((entry) => entry.showInDrawer).toList();

    _isInitialized = true;
  }

  static List<NavigationEntry> get navigationEntries {
    _ensureInitialized();
    return _navigationEntries;
  }

  static NavigationEntry? getEntryByPath(String path) {
    _ensureInitialized();
    return _pathToEntry[path];
  }

  static NavigationEntry? getEntryByName(String name) {
    _ensureInitialized();
    return _nameToEntry[name];
  }

  static NavigationEntry? getEntryByIndex(int index) {
    _ensureInitialized();
    return _indexToEntry[index];
  }

  static List<NavigationEntry> getBottomNavEntries() {
    _ensureInitialized();
    return _bottomNavEntries!;
  }

  static List<NavigationEntry> getDrawerEntries() {
    _ensureInitialized();
    return _drawerEntries!;
  }

  static int getBottomNavIndex(int tabIndex) {
    _ensureInitialized();
    final bottomNavEntries = _bottomNavEntries!;
    for (int i = 0; i < bottomNavEntries.length; i++) {
      if (bottomNavEntries[i].index == tabIndex) {
        return i;
      }
    }
    return 0; // Default to home
  }

  static int getTabIndexFromBottomNav(int bottomNavIndex) {
    _ensureInitialized();
    final bottomNavEntries = _bottomNavEntries!;
    if (bottomNavIndex >= 0 && bottomNavIndex < bottomNavEntries.length) {
      return bottomNavEntries[bottomNavIndex].index;
    }
    return 0; // Default to home
  }

  static void navigateToPath(String path) {
    final entry = getEntryByPath(path);
    if (entry != null) {
      Globals().tabController.animateTo(entry.index);
    }
  }

  static void navigateToEntry(NavigationEntry entry) {
    Globals().tabController.animateTo(entry.index);
  }

  static void _ensureInitialized() {
    if (!_isInitialized) {
      initialize();
    }
  }
} 