import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/helpers/environment.dart';
import 'package:threebotlogin/helpers/flags.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/kyc_helpers.dart';
import 'package:threebotlogin/screens/home_screen.dart';
import 'package:threebotlogin/screens/init_screen.dart';
import 'package:threebotlogin/screens/unregistered_screen.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/migration_service.dart';
import 'package:threebotlogin/services/socket_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/error_widget.dart';
import 'package:uni_links/uni_links.dart';

class MainScreen extends StatefulWidget {
  final bool? initDone;
  final bool? registered;

  MainScreen({this.initDone, this.registered});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MainScreen> {
  StreamSubscription? _sub;
  String? initialLink;
  String? updateMessage = '';
  String? errorMessage;

  late BackendConnection _backendConnection;

  @override
  void initState() {
    super.initState();
    Events().reset();
    // _listener = FirebaseNotificationListener();
    WidgetsBinding.instance?.addPostFrameCallback((_) => pushScreens());
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

    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/logo.png',
          height: 100,
        ),
        SizedBox(
          height: 40,
        ),
        Container(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Text(
            updateMessage != null ? updateMessage.toString() : errorMessage.toString(),
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: errorMessage != null ? Colors.red : Colors.black),
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Transform.scale(
          scale: 0.5,
          child: CircularProgressIndicator(
            color: Color.fromRGBO(0, 174, 239, 1),
          ),
        ),
        SizedBox(height: 20),
        Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: errorMessage != null,
            child: RaisedButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30),
              ),
              color: Theme.of(context).accentColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'RETRY',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              onPressed: () async {
                await pushScreens();
              },
            ))
      ],
    )));
  }

  pushScreens() async {
    try {
      errorMessage = null;
      updateMessage = 'Checking internet connection';
      setState(() {});
      await checkInternetConnection();

      updateMessage = 'Checking connection to our server';
      setState(() {});
      await checkInternetConnectionWithOurServers();

      updateMessage = 'Checking connection to FlagSmith';
      setState(() {});

      await Flags().initFlagSmith();
      await Flags().setFlagSmithDefaultValues();

      updateMessage = 'Checking if app is under maintenance';
      setState(() {});
      await checkIfAppIsUnderMaintenance();

      updateMessage = 'Checking if app is up to date';
      setState(() {});
      await checkIfAppIsUpToDate();

      updateMessage = 'Checking connection to pkid';
      setState(() {});
      await checkConnectionToPkid();

      updateMessage = 'Fetching pkid data';
      setState(() {});
      await fetchPkidData();
    } catch (e) {
      print('Error in main screen');
      print(e);

      updateMessage = null;
      errorMessage = e.toString().split('Exception:')[1];
      setState(() {});
      return;
    }

    if (widget.initDone != null && !widget.initDone!) {
      InitScreen init = InitScreen();
      bool accepted = false;
      while (!accepted) {
        accepted = !(await Navigator.push(context, MaterialPageRoute(builder: (context) => init)) == null);
      }
    }

    if (!widget.registered!) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => UnregisteredScreen()));
    }

    await Globals().router.init();

    _backendConnection = BackendConnection((await getDoubleName())!);
    _backendConnection.init();

    await initUniLinks();

    if (_sub != null) {
      _sub?.cancel();
    }

    print(mounted);

    // await Navigator.push(context, MaterialPageRoute(builder: (context) => UnregisteredScreen()));
    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(initialLink: initialLink, backendConnection: _backendConnection)));
  }

  fetchPkidData() async {
    try {
      String? seedPhrase = await getPhrase();

      if (seedPhrase != null &&
          (await isPKidMigrationIssueSolved() == false || await isPKidMigrationIssueSolved() == null)) {
        fixPkidMigration();
      }

      if (await getPhrase() != null) {
        await fetchPKidData();
      }
    } catch (e) {
      print(e);
      throw Exception('Unable to fetch pkid data');
    }
  }

  checkInternetConnection() async {
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('google.com').timeout(Duration(seconds: Globals().timeOutSeconds));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('Connected to the internet');
      }
    } catch (e) {
      throw new Exception("No internet connection available, please make sure you have a stable internet connection.");
    }
  }

  checkInternetConnectionWithOurServers() async {
    if (AppConfig().environment != Environment.Local) {
      try {
        String baseUrl = AppConfig().baseUrl();
        final List<InternetAddress> result =
            await InternetAddress.lookup('$baseUrl').timeout(Duration(seconds: Globals().timeOutSeconds));

        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('Connected to the servers');
        }
      } catch (e) {
        throw new Exception("Can't connect to our servers, please try again. Contact support if this issue persists.");
      }
    }
  }

  checkConnectionToPkid() async {
    try {
      if (!!await checkIfPkidIsAvailable()) {
        throw new Exception(
            "Can't connect to our pkid service, please try again. Contact support if this issue persists.");
      }
    } catch (e) {
      throw new Exception(
          "Can't connect to our pkid service, please try again. Contact support if this issue persists.");
    }
  }

  checkIfAppIsUnderMaintenance() async {
    bool isUnderMaintenanceInFlagSmith = Globals().maintenance;
    if (isUnderMaintenanceInFlagSmith == true) {
      throw new Exception('App is being rolled out. Please try again later.');
    }

    try {
      if (await isAppUnderMaintenance()) {
        throw new Exception('App is being rolled out. Please try again later.');
      }
    } catch (e) {
      throw new Exception("App is being rolled out. Please try again later.");
    }
  }

  checkIfAppIsUpToDate() async {
    try {
      if (!await isAppUpToDate()) {
        throw new Exception('The app is outdated. Please, update it to the latest version');
      }
    } catch (e) {
      throw new Exception("The app is outdated. Please, update it to the latest version");
    }
  }

  Future<Null> initUniLinks() async {
    initialLink = await getInitialLink();

    // Doesn't seem needed in this scenario. Might be removed in the future.
    _sub = getLinksStream().listen((String? incomingLink) {
      if (!mounted) {
        return;
      }
      initialLink = incomingLink;
    });
  }
}
