import 'package:flutter/material.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/views/farmer/views/farmer.view.dart';
import 'package:threebotlogin/views/home/views/home.view.dart';
import 'package:threebotlogin/views/identity/views/identity.view.dart';
import 'package:threebotlogin/views/news/views/news.view.dart';
import 'package:threebotlogin/views/settings/views/settings.view.dart';
import 'package:threebotlogin/views/support/views/support.view.dart';
import 'package:threebotlogin/views/wallet/views/wallet.view.dart';
import 'package:threebotlogin/views/yggdrasil/views/yggdrasil.view.dart';

class JRoute {
  // Needs to be dynamic since we want to support images as Icons too
  final dynamic icon;
  final String name;
  final String path;
  final Widget view;
  final bool canSee;
  final bool? emailRequired;
  final bool? pinRequired;

  JRoute(
      {required this.path,
      required this.name,
      required this.icon,
      required this.view,
      required this.canSee,
      this.emailRequired,
      this.pinRequired});
}

class JRouter {
  List<AppInfo> routes = [];

  init() async {
    routes = [
      AppInfo(
          route: JRoute(
        path: '/',
        name: 'Home',
        icon: Icon(Icons.home, color: Colors.black, size: 18),
        canSee: true,
        view: HomeScreen(),
      )),
      AppInfo(
          route: JRoute(
        path: '/news',
        name: 'News',
        icon: Icon(Icons.article, color: Colors.black, size: 18),
        canSee: Globals().canSeeNews,
        view: NewsScreen(),
      )),
      AppInfo(
          route: JRoute(
        path: '/wallet',
        name: 'Wallet',
        icon: Icon(Icons.wallet, color: Colors.black, size: 18),
        canSee: Globals().canSeeWallet,
        pinRequired: true,
        view: WalletScreen(),
      )),
      AppInfo(
          route: JRoute(
        path: '/farming',
        name: 'Farming',
        icon: Image.asset(
          'assets/server.png',
          scale: 1.0,
          height: 18.0,
          width: 18.0,
        ),
        canSee: Globals().canSeeFarmer,
        pinRequired: true,
        view: FarmerScreen(),
      )),
      AppInfo(
          route: JRoute(
        path: '/support',
        name: 'Support',
        icon: Icon(Icons.chat, color: Colors.black, size: 18),
        canSee: Globals().canSeeSupport,
        view: SupportScreen(),
      )),
      AppInfo(
          route: JRoute(
        path: '/yggdrasil',
        name: 'Planetary Network',
        icon: Icon(Icons.network_check, color: Colors.black, size: 18),
        canSee: Globals().canSeeYggdrasil,
        view: YggDrasilScreen(),
      )),
      AppInfo(
          route: JRoute(
        path: '/identity',
        name: 'Identity',
        icon: Icon(Icons.person, color: Colors.black, size: 18),
        canSee: Globals().canSeeKyc,
        view: IdentityScreen(),
      )),
      AppInfo(
          route: JRoute(
        path: '/settings',
        name: 'Settings',
        icon: Icon(Icons.settings, color: Colors.black, size: 18),
        canSee: true,
        view: SettingsScreen(),
      )),
    ];
  }

  List<Widget> getContent() {
    List<Widget> containers = [];
    routes.forEach((r) {
      containers.add(r.route.view);
    });
    return containers;
  }

  bool pinRequired(int index) {
    if (routes[index].route.pinRequired != null) {
      return true;
    }
    return false;
  }
}

class AppInfo {
  JRoute route;

  AppInfo({required this.route});
}
