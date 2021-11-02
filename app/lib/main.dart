import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/screens/main_screen.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/logging_service.dart';
import 'package:threebotlogin/services/migration_service.dart';
import 'package:threebotlogin/services/pkid_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers/flags.dart';
import 'helpers/kyc_helpers.dart';

LoggingService logger;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences.setMockInitialValues({});
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  bool initDone = await getInitDone();
  String doubleName = await getDoubleName();

  await setGlobalValues();
  await saveCorrectKYCLevel();

  bool registered = doubleName != null;

  await Flags().initialiseFlagSmith();
  await Flags().setFlagSmithDefaultValues();

  if(await getPhrase() != null) {
    await migrateToNewSystem();
  }

  runApp(MyApp(initDone: initDone, registered: registered));
}

Future<void> setGlobalValues() async {
  Map<String, Object> email = await getEmail();
  Map<String, Object> phone = await getPhone();
  Map<String, dynamic> identity = await getIdentity();

  Globals().emailVerified.value = (email['sei'] != null);
  Globals().phoneVerified.value = (phone['spi'] != null);
  Globals().identityVerified.value = (identity['signedIdentityNameIdentifier'] != null);

}

class MyApp extends StatelessWidget {
  MyApp({this.initDone, this.doubleName, this.registered});

  final bool initDone;
  final String doubleName;
  final bool registered;

  @override
  Widget build(BuildContext context) {
    var textTheme = GoogleFonts.latoTextTheme(
      Theme.of(context).textTheme,
    );
    var accentTextTheme = GoogleFonts.latoTextTheme(
      Theme.of(context).accentTextTheme,
    );
    var textStyle = GoogleFonts.lato();
    return MaterialApp(
      theme: ThemeData(
        primaryColor: HexColor("#0a73b8"),
        accentColor: HexColor("#57BE8E"),
        textTheme: textTheme,
        tabBarTheme: TabBarTheme(labelStyle: textStyle, unselectedLabelStyle: textStyle),
        appBarTheme: AppBarTheme(color: Colors.white, textTheme: accentTextTheme, brightness: Brightness.dark),
      ),
      home: MainScreen(initDone: initDone, registered: registered),
    );
  }
}