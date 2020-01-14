import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpEvents.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/ffp.dart';
import 'package:threebotlogin/Events/Events.dart';
import 'package:threebotlogin/Events/GoHomeEvent.dart';
import 'package:threebotlogin/Events/NewLoginEvent.dart';
import 'package:threebotlogin/Events/UniLinkEvent.dart';
import 'package:threebotlogin/helpers/Globals.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/services/UniLinkService.dart';
import 'package:threebotlogin/services/socketService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/EmailVerificationNeeded.dart';
import 'package:threebotlogin/widgets/PinFieldNew.dart';
import 'package:uni_links/uni_links.dart';

/* Screen shows tabbar and all pages defined in router.dart */
class HomeScreen extends StatefulWidget {
  final String initialLink;

  HomeScreen({this.initialLink});

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  TabController _tabController;
  StreamSubscription _sub;
  String initialLink;
  bool backgroundSincePinCheck = true;
  bool pinCheckOpen = false;
  int lastPinCheck = 0;
  final int pinCheckTimeout = 60000 * 5; //5 minutes in milliseconds

  _HomeScreenState() {
    _tabController = TabController(
        initialIndex: 0, length: Globals().router.routes.length, vsync: this);
    Events().onEvent(FfpBrowseEvent().runtimeType, activateFfpTab);
    _tabController.addListener(_handleTabSelection);
  }
  bool checkPinAgain() {
    var now = new DateTime.now().millisecondsSinceEpoch;
    return (now - lastPinCheck > pinCheckTimeout) && backgroundSincePinCheck;
  }

  void checkPin() async {
    String correctPin = await getPin();
    pinCheckOpen = true;
    bool pinIsCorrect = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PinFieldNew(correctPin: correctPin)));
    pinCheckOpen = false;
    if (pinIsCorrect == null || !pinIsCorrect) {
      _tabController.animateTo(_tabController.previousIndex);
    } else {
      lastPinCheck = new DateTime.now().millisecondsSinceEpoch;
      backgroundSincePinCheck = false;
    }
  }

  _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      if (Globals().router.pinRequired(_tabController.index) &&
          checkPinAgain() && !pinCheckOpen) {
        checkPin();
      }

      if (Globals().router.emailMustBeVerified(_tabController.index) &&
          !Globals().emailVerified.value) {
        _tabController.animateTo(_tabController.previousIndex);
        await emailVerificationDialog(context);
      }
    }
  }

  activateFfpTab(FfpBrowseEvent event) {
    int ffpTab = 2;
    Ffp().firstUrlToLoad = event.url;
    setState(() {
      _tabController.animateTo(ffpTab);
    });
  }

  close(GoHomeEvent e) {
    int homeTab = 0; //@todo can we do some indexoff on routes
    _tabController.animateTo(homeTab);
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();

    Events().onEvent(GoHomeEvent().runtimeType, close);
    Events().onEvent(NewLoginEvent().runtimeType, (NewLoginEvent event) {
      openLogin(context, event.data);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _sub.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if(pinCheckOpen){
        return;
      }
      backgroundSincePinCheck = true;
      if (Globals().router.pinRequired(_tabController.index) &&
          checkPinAgain()) {
        checkPin();
      }
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
    }
  }

  Future<Null> initUniLinks() async {
    Events().onEvent(
        UniLinkEvent(null, null).runtimeType, UniLinkService.handleUniLink);
    initialLink = widget.initialLink;

    if (initialLink != null) {
      Events().emit(UniLinkEvent(Uri.parse(initialLink), context));
    }
    _sub = getLinksStream().listen((String incomingLink) {
      if (!mounted) {
        return;
      }
      Events().emit(UniLinkEvent(Uri.parse(incomingLink), context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: Globals().router.routes.length,
      child: WillPopScope(
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
        onWillPop: onWillPop,
      ),
    );
  }

  Future<bool> onWillPop() {
    if (_tabController.index == 0) {
      return Future(() => true); // if home screen exit
    }
    if (Globals().router.routes[_tabController.index].app == null) {
      Events().emit(GoHomeEvent()); // if not an app, eg settings, go home
    }
    Globals()
        .router
        .routes[_tabController.index]
        .app
        .back(); // if app ask app to handle back event

    return Future(() => false);
  }
}
