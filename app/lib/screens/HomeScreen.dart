import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpEvents.dart';
import 'package:threebotlogin/Events/Events.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/socketService.dart';
import 'package:threebotlogin/services/uniLinkService.dart';
import 'package:threebotlogin/widgets/EmailVerificationNeeded.dart';
import 'package:uni_links/uni_links.dart';

/* Screen shows tabbar and all pages defined in router.dart */
class HomeScreen extends StatefulWidget {
  HomeScreen();

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  TabController _tabController;
  StreamSubscription _sub;

  _HomeScreenState() {
    _tabController = TabController(
        initialIndex: 0, length: Globals().router.routes.length, vsync: this);
    Events().onEvent(FfpBrowseEvent().runtimeType, activateFfpTab);
    _tabController.addListener(_handleTabSelection);
  }

  _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      if (Globals().router.emailMustBeVerified(_tabController.index) && !Globals().emailVerified.value) {
        _tabController.animateTo(_tabController.previousIndex);
        await emailVerificationDialog(context);
      }
    }
  }

  activateFfpTab(FfpBrowseEvent event) {
    int ffpTab = 2;
    setState(() {
      _tabController.animateTo(ffpTab);
    });
  }

  @override
  void initState() {
    super.initState();
    _sub = getLinksStream().listen((String incomingLink) {
      checkWhatPageToOpen(Uri.parse(incomingLink), context);
    });
    createSocketConnection(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: Globals().router.routes.length,
      child: Scaffold(
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: Globals().router.getContent(),
          ),
        ),
        bottomNavigationBar: Container(
          color: HexColor("#2d4052"), //@todo theme obj
          padding: EdgeInsets.all(0.0),
          height: 65,
          margin: EdgeInsets.all(0.0),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: Globals().router.getAppButtons(),
            labelPadding: EdgeInsets.all(0.0),
            indicatorPadding: EdgeInsets.all(0.0),
          ),
        ),
      ),
    );
  }
}
