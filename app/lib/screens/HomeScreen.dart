import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpEvents.dart';
import 'package:threebotlogin/Events/Events.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/socketService.dart';

/* Screen shows tabbar and all pages defined in router.dart */
class HomeScreen extends StatefulWidget {
  final String doubleName;

  HomeScreen({this.doubleName});

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  TabController tabController;

  _HomeScreenState() {
    tabController = TabController(
        initialIndex: 0, length: Globals().router.routes.length, vsync: this);
    Events().onEvent(FfpBrowseEvent().runtimeType, activateFfpTab);
  }
  activateFfpTab(FfpBrowseEvent event) {
    int ffpTab = 2;
    setState(() {
      tabController.animateTo(ffpTab);
    });
  }

  @override
  void initState() {
    super.initState();
    createSocketConnection(context, widget.doubleName);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: Globals().router.routes.length,
      child: Scaffold(
        body: SafeArea(
          child: TabBarView(
            controller: tabController,
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
            controller: tabController,
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
