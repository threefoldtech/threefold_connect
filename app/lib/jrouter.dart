import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/council/council.dart';
import 'package:threebotlogin/apps/dao/dao.dart';
import 'package:threebotlogin/apps/market/market.dart';
import 'package:threebotlogin/apps/wallet/wallet.dart';
import 'package:threebotlogin/screens/identity_screen.dart';
import 'package:threebotlogin/screens/preference_screen.dart';
import 'package:threebotlogin/apps/notifications/notifications.dart';
import 'apps/farmers/farmers.dart';
import 'apps/news/news.dart';
import 'apps/sign/sign.dart';

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
            path: '/farming',
            name: 'Farming',
            icon: Icons.storage,
            view: await Farmers().widget(),
          ),
          app: Farmers()),
      AppInfo(
          route: Route(
            path: '/dao',
            name: 'Dao',
            icon: Icons.how_to_vote_outlined,
            view: await Dao().widget(),
          ),
          app: Dao()),
      AppInfo(
          route: Route(
            path: '/identity',
            name: 'Identity',
            icon: Icons.lock,
            view: const IdentityScreen(),
          ),
          app: null),
      AppInfo(
        route: Route(
          path: '/market',
          name: 'Market',
          icon: Icons.show_chart_sharp,
          view: await Market().widget(),
        ),
        app: Market(),
      ),
      AppInfo(
          route: Route(
            path: '/settings',
            name: 'Settings',
            icon: Icons.settings,
            view: const PreferenceScreen(),
          ),
          app: null),
      AppInfo(
          route: Route(
            path: '/council',
            name: 'Council',
            icon: Icons.how_to_vote_outlined,
            view: await Council().widget(),
          ),
          app: Dao()),
      AppInfo(
          route: Route(
            path: '/sign',
            name: 'Sign',
            icon: Icons.draw_sharp,
            view: await Sign().widget(),
          ),
          app: Sign()),
      AppInfo(
          route: Route(
            path: '/notifications',
            name: 'Notifications',
            icon: Icons.notifications,
            view: await Notifications().widget(),
          ),
          app: null),
    ];
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
    for (var r in routes) {
      containers.add(r.route.view);
    }
    return containers;
  }

  List<Tab> getAppButtons() {
    List<Tab> iconButtons = [];
    for (var r in routes) {
      iconButtons.add(Tab(
        icon: Icon(
          r.route.icon,
          size: 40,
        ),
        text: r.route.name,
      ));
    }
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
