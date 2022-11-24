import 'dart:async';
import 'package:flutter/material.dart';
import 'package:threebotlogin/core/auth/pin/views/auth.view.dart';
import 'package:threebotlogin/core/enums/core.enum.dart';
import 'package:threebotlogin/core/events/classes/event.classes.dart';
import 'package:threebotlogin/core/storage/auth/auth.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';
import 'package:threebotlogin/login/helpers/login.helpers.dart';
import 'package:uni_links/uni_links.dart';

class TabsScreen extends StatefulWidget {
  TabsScreen();

  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  _TabsScreenState();

  StreamSubscription? _sub;

  bool timeoutExpiredInBackground = true;
  bool pinCheckOpen = false;

  void checkPinAndNavigateIfSuccess(int indexIfAuthIsSuccess) async {
    String? pin = await getPin();
    pinCheckOpen = true;

    bool? authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
          correctPin: pin!,
          userMessage: "Please enter your PIN code",
        ),
      ),
    );

    pinCheckOpen = false;

    if (authenticated != null && authenticated) {
      timeoutExpiredInBackground = false;
      Globals().tabController.animateTo(indexIfAuthIsSuccess);
    }
  }

  _handleTabSelection() async {
    if (!Globals().tabController.indexIsChanging) {
      return;
    }

    if (Globals().router.pinRequired(Globals().tabController.index) && timeoutExpiredInBackground && !pinCheckOpen) {
      int authenticatedAppIndex = Globals().tabController.index;
      Globals().tabController.animateTo(Globals().tabController.previousIndex);

      checkPinAndNavigateIfSuccess(authenticatedAppIndex);
    }
  }

  close(GoHomeEvent e) {
    Globals().tabController.animateTo(0);
  }

  @override
  void initState() {
    super.initState();

    Globals().tabController = TabController(initialIndex: 0, length: Globals().router.routes.length, vsync: this);
    Globals().tabController.addListener(_handleTabSelection);

    _handleIncomingUniLinks();
    WidgetsBinding.instance.addObserver(this);
  }

  void _handleIncomingUniLinks() async {
    _sub = uriLinkStream.listen((Uri? url) async {
      if (!mounted) return;
      if (url == null) return;

      print('Received URI: $url');
      print(url.host);

      if (url.host == UniLinkTypes.login) {
        await openLoginMobile(url);
      }

      if (url.host == UniLinkTypes.sign) {
        // return await handleSignUniLink(link, context);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  Widget build(BuildContext context) {
    Globals().globalBuildContext = context;

    return Scaffold(
      appBar: PreferredSize(
        child: new AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: kAppBarColor,
        ),
        preferredSize: Size.fromHeight(0),
      ),
      body: DefaultTabController(
        length: Globals().router.routes.length,
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              SafeArea(
                  child: TabBarView(
                controller: Globals().tabController,
                physics: NeverScrollableScrollPhysics(),
                children: Globals().router.getContent(),
              )),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
