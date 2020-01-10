import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/Events/Events.dart';
import 'package:threebotlogin/helpers/Globals.dart';
import 'package:threebotlogin/screens/HomeScreen.dart';
import 'package:threebotlogin/screens/InitScreen.dart';
import 'package:threebotlogin/screens/UnregisteredScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/socketService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:threebotlogin/widgets/ErrorWidget.dart';
import 'package:uni_links/uni_links.dart';

class MainScreen extends StatefulWidget {
  final bool initDone;
  final bool registered;

  MainScreen({this.initDone, this.registered});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MainScreen> {
  _AppState();
  StreamSubscription _sub;
  String initialLink;
  BackendConnection _backendConnection;

  pushScreens() async {

    // Internet connection check. 
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected to the internet');
      }
    } on SocketException catch (_) {
      var dialog = CustomDialog(
          title: "No internet connection available",
          description: Text(
            "Please enable your internet connection to use this app.",
            textAlign: TextAlign.center,
          ));
      await dialog.show(context);
      SystemNavigator.pop();
    }

    // Version check. TODO: Maybe add a button to open the app / playstore?
    if(!await isAppUpToDate()) {
      var dialog = CustomDialog(
        title: "Update required",
        description: Text(
          "The app is outdated. Please, update it to the latest version.",
          textAlign: TextAlign.center,
      ));

      await dialog.show(context);
      SystemNavigator.pop();
    }

    if (widget.initDone != null && !widget.initDone) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => InitScreen()));
    }

    if (!widget.registered) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => UnregisteredScreen()));
    }

    await Globals().router.init();

    _backendConnection = BackendConnection(await getDoubleName());
    _backendConnection.init();
    if(_sub != null){
    _sub.cancel();
    }

    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  initialLink: initialLink,
                )));
  }

  @override
  void initState() {
    super.initState();
    Events().reset();
    initUniLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) => pushScreens());
  }

  Future<Null> initUniLinks() async {
    initialLink = await getInitialLink();

    _sub = getLinksStream().listen((String incomingLink) {
      if (!mounted) {
        return;
      }
      initialLink = incomingLink;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };

    return Container();
  }
}
