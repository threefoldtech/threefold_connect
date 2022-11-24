import 'dart:io';

import 'package:flutter/material.dart';
import 'package:threebotlogin/api/3bot/services/connection.service.dart';
import 'package:threebotlogin/core/components/tabs/tabs.view.dart';
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/config/enums/config.enums.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/pkid/classes/pkid.classes.dart';
import 'package:threebotlogin/sockets/classes/socket.classes.dart';
import 'package:threebotlogin/views/landing/views/landing.view.dart';
import 'package:threebotlogin/views/wizard/views/wizard.view.dart';

Future<void> checkInternetConnection() async {
  try {
    await InternetAddress.lookup('google.com').timeout(Duration(seconds: Globals().httpTimeout));
  } catch (e) {
    throw new Exception("No internet connection available, please make sure you have a stable internet connection.");
  }
}

Future<void> checkInternetConnectionWithOurServers() async {
  if (AppConfig().environment == Environment.Local) return;

  try {
    String baseUrl = AppConfig().baseUrl();
    await InternetAddress.lookup('$baseUrl').timeout(Duration(seconds: Globals().httpTimeout));
  } catch (e) {
    print(e);
    throw new Exception("Can't connect to our servers, please try again. Contact support if this issue persists.");
  }
}

Future<void> checkConnectionToPkid() async {
  try {
    if (!await checkIfPkidIsAvailable()) {
      throw new Exception(
          "Can't connect to our pkid service, please try again. Contact support if this issue persists.");
    }
  } catch (e) {
    print(e);
    throw new Exception("Can't connect to our pkid service, please try again. Contact support if this issue persists.");
  }
}

Future<void> checkIfAppIsUnderMaintenance() async {
  bool isUnderMaintenanceInFlagSmith = Globals().maintenance;
  if (isUnderMaintenanceInFlagSmith == true) {
    throw new Exception('App is being rolled out. Please try again later.');
  }

  try {
    if (await isAppUnderMaintenance()) {
      throw new Exception('App is being rolled out. Please try again later.');
    }
  } catch (e) {
    print(e);
    throw new Exception("App is being rolled out. Please try again later.");
  }
}

Future<void> checkIfAppIsUpToDate() async {
  try {
    if (!await isAppUpToDate()) {
      throw new Exception('The app is outdated. Please, update it to the latest version');
    }
  } catch (e) {
    print(e);
    throw new Exception("The app is outdated. Please, update it to the latest version");
  }
}

Future<void> navigateToCorrectPage() async {
  String? username = await getUsername();
  bool initDone = await getInitialized();

  // User is already registered
  if (username != null && initDone == true) {
    await PkidClient(username, (await getPhrase())!).initializePkidClient(true);
    await SocketConnection(username).initializeSocketClient();

    await Navigator.pushReplacement(
        Globals().globalBuildContext, MaterialPageRoute(builder: (context) => TabsScreen()));
  }

  // User has done wizard, but is not registered yet
  if (username == null && initDone == true) {
    await Navigator.pushReplacement(
        Globals().globalBuildContext, MaterialPageRoute(builder: (context) => LandingScreen()));
  }

  // Wizard not done + may see wizard
  if (initDone == false && Globals().canSeeWizard) {
    await Navigator.pushReplacement(
        Globals().globalBuildContext, MaterialPageRoute(builder: (context) => WizardScreen()));
  }

  // Initialization is not done but neither may see wizard
  if (initDone == false && !Globals().canSeeWizard) {
    await Navigator.pushReplacement(
        Globals().globalBuildContext, MaterialPageRoute(builder: (context) => LandingScreen()));
  }
}
