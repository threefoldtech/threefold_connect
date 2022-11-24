import 'package:flutter/material.dart';
import 'package:threebotlogin/core/components/dividers/box.dividers.dart';
import 'package:threebotlogin/core/components/spinners/loaders.spinners.dart';
import 'package:threebotlogin/core/flagsmith/classes/flagsmith.class.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/views/connection/helpers/connection.helpers.dart';
import 'package:threebotlogin/views/connection/widgets/connection.widgets.dart';

class ConnectionScreen extends StatefulWidget {
  ConnectionScreen();

  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> with WidgetsBindingObserver {
  _ConnectionScreenState();

  String? updateMessage = 'Loading';
  String? errorMessage;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkAvailability());
  }

  @override
  Widget build(BuildContext context) {
    Globals().globalBuildContext = context;
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        logo,
        kSizedBoxL,
        message(this.updateMessage, errorMessage),
        kSizedBoxL,
        kLoadingSpinnerXs,
        kSizedBoxSm,
        retryButton(errorMessage, checkAvailability)
      ],
    )));
  }

  void checkAvailability() async {
    try {
      errorMessage = null;
      updateMessage = 'Checking internet connection';
      setState(() {});
      await checkInternetConnection();

      updateMessage = 'Checking connection to FlagSmith';
      setState(() {});

      await Flags().initFlagSmith();
      await Flags().setFlagSmithDefaultValues();

      updateMessage = 'Checking connection to our server';
      setState(() {});
      await checkInternetConnectionWithOurServers();

      updateMessage = 'Checking if app is under maintenance';
      setState(() {});
      await checkIfAppIsUnderMaintenance();

      updateMessage = 'Checking if app is up to date';
      setState(() {});
      await checkIfAppIsUpToDate();

      updateMessage = 'Checking connection to pkid';
      setState(() {});
      await checkConnectionToPkid();

      await Globals().router.init();

      await navigateToCorrectPage();

    } catch (e) {
      print(e);
      updateMessage = null;
      errorMessage = e.toString().split('Exception:')[1];
      setState(() {});
    }
  }
}
