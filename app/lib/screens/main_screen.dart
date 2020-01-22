import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/helpers/environment.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/screens/home_screen.dart';
import 'package:threebotlogin/screens/init_screen.dart';
import 'package:threebotlogin/screens/unregistered_screen.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/socket_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/error_widget.dart';
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

  @override
  void initState() {
    super.initState();
    Events().reset();
    initUniLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) => pushScreens());
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

  pushScreens() async {
    checkInternetConnection();
    checkInternetConnectionWithOurServers();
    checkIfAppIsUpToDate();

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
    if (_sub != null) {
      _sub.cancel();
    }

    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  initialLink: initialLink,
                )));
  }

  checkInternetConnection() async {
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
  }

  checkInternetConnectionWithOurServers() async {
    if (AppConfig().environment != Environment.Local) {
      try {
        String baseUrl = AppConfig().baseUrl();
        final result = await InternetAddress.lookup('$baseUrl');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('connected to the internet');
        }
      } on SocketException catch (_) {
        var dialog = CustomDialog(
            title: "Oops",
            description: Text(
              "Something went wrong, please try again. Contact support if this issue persists.",
              textAlign: TextAlign.center,
            ));
        await dialog.show(context);
        SystemNavigator.pop();
      }
    }
  }

  checkIfAppIsUpToDate() async {
    if (!await isAppUpToDate()) {
      var dialog = CustomDialog(
          title: "Update required",
          description: Text(
            "The app is outdated. Please, update it to the latest version.",
            textAlign: TextAlign.center,
          ));

      await dialog.show(context);
      SystemNavigator.pop();
    }
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
}
