import 'package:flutter/material.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/ffp.dart';
import 'package:threebotlogin/Apps/Wallet/wallet.dart';
import 'package:threebotlogin/screens/HomeScreen.dart';
import 'package:threebotlogin/screens/PreferenceWidget.dart';

class Router {
  List<Route> routes = [
    Route(
        path: '/',
        name: 'Home',
        icon: Icons.home,
        view: HomeScreen(),
    ),
    Route(
        path: '/wallet',
        name: 'Pay',
        icon: Icons.account_balance_wallet,
        view: Wallet().widget(),
    ),
    Route(
      path: '/ffp',
      name: 'Social',
      icon: Icons.person,
      view: Ffp().widget(),
    ),
     Route(
      path: '/settings',
      name: 'Settings',
      icon: Icons.settings,
      view: PreferencePage(),
    ),
  ];
  Map<String, Widget Function(BuildContext)> getRoutes() {
    return Map.fromIterable(routes, key: (v) => v.path, value: (v) => v.view);
  }
  List<Widget> getContent() {
    List<Widget> containers = [];
    routes.forEach((r) {
      containers.add(r.view);
    });
    return containers;
  }

  List<Tab> getIconButtons() {
    List<Tab> iconButtons = [];
    routes.forEach((r) {
      iconButtons.add(Tab(
        icon: Icon(r.icon),
        text: r.name,
      ));
    });
    return iconButtons;
  }
}

class Route {
  final IconData icon;
  final String name;
  final String path;
  final Widget view;

  Route({this.path, this.name, this.icon, this.view});
}
