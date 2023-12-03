import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/chatbot/chatbot.dart';
import 'package:threebotlogin/apps/wallet/wallet.dart';
import 'package:threebotlogin/screens/identity_verification_screen.dart';
import 'package:threebotlogin/screens/preference_screen.dart';
import 'package:threebotlogin/screens/registered_screen.dart';

import 'apps/farmers/farmers.dart';
import 'apps/news/news.dart';

class AppInfo {
  Route route;
  App? app;

  AppInfo({required this.route, this.app});
}

class JRouter {
  List<AppInfo> routes = [];

  init() async {
    routes = [
      AppInfo(
          route: Route(
            path: '/',
            name: 'Home',
            icon: Icons.home,
            view: RegisteredScreen(),
          ),
          app: null),
      AppInfo(
          route: Route(
            path: '/news',
            name: 'News',
            icon: Icons.article,
            view: await News().widget(),
          ),
          app: News()),
      AppInfo(
          route: Route(
            path: '/wallet',
            name: 'Wallet',
            icon: Icons.account_balance_wallet,
            view: await Wallet().widget(),
          ),
          app: Wallet()),
      AppInfo(
          route: Route(
            path: '/farmers',
            name: 'Farmers',
            icon: Icons.person_pin,
            view: await Farmers().widget(),
          ),
          app: Farmers()),
      AppInfo(
          route: Route(
            path: '/chatbot',
            name: 'Support',
            icon: Icons.chat,
            view: await Chatbot().widget(),
          ),
          app: Chatbot()),
      AppInfo(
          route: Route(
            path: '/identityverification',
            name: 'IdentityVerification',
            icon: Icons.lock,
            view: IdentityVerificationScreen(),
          ),
          app: null),
      AppInfo(
          route: Route(
            path: '/settings',
            name: 'Settings',
            icon: Icons.settings,
            view: PreferenceScreen(),
          ),
          app: null),
    ];
  }

  Map<String, Widget Function(BuildContext)> getRoutes() {
    return Map.fromIterable(routes, key: (v) => v.path, value: (v) => v.view);
  }

  bool emailMustBeVerified(int index) {
    if (routes[index].app != null) {
      return routes[index].app!.emailVerificationRequired();
    }
    return false;
  }

  bool pinRequired(int index) {
    if (routes[index].app != null) {
      return routes[index].app!.pinRequired();
    }
    return false;
  }

  List<Widget> getContent() {
    List<Widget> containers = [];
    routes.forEach((r) {
      containers.add(r.route.view);
    });
    return containers;
  }

  List<Tab> getAppButtons() {
    List<Tab> iconButtons = [];
    routes.forEach((r) {
      iconButtons.add(Tab(
        icon: Icon(
          r.route.icon,
          size: 40,
        ),
        text: r.route.name,
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

  Route(
      {required this.path,
      required this.name,
      required this.icon,
      required this.view});
}
