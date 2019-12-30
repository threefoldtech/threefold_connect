import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/router.dart';
import 'package:threebotlogin/services/socketService.dart';

/* Screen shows tabbar and all pages defined in router.dart */
class HomeScreen extends StatefulWidget {
  final Router router;
  final String doubleName;

  HomeScreen({this.router, this.doubleName});

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    createSocketConnection(context, widget.doubleName);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.router.routes.length,
      child: Scaffold(
        body: SafeArea(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: widget.router.getContent(),
          ),
        ),
        bottomNavigationBar: Container(
          color: HexColor("#2d4052"), //@todo theme obj
          padding: EdgeInsets.all(0.0),
          height: 65,
          margin: EdgeInsets.all(0.0),
          child: TabBar(
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: widget.router.getIconButtons(),
            labelPadding: EdgeInsets.all(0.0),
            indicatorPadding: EdgeInsets.all(0.0),
          ),
        ),
      ),
    );
  }
}
