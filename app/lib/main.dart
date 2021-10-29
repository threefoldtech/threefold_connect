import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/screens/main_screen.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/logging_service.dart';
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

  Map<String, Object> email = await getEmail();
  Map<String, Object> phone = await getPhone();
  Map<String, dynamic> identity = await getIdentity();

  Globals().emailVerified.value = (email['sei'] != null);
  Globals().phoneVerified.value = (phone['spi'] != null);
  Globals().identityVerified.value = (identity['signedIdentityNameIdentifier'] != null);

  await saveCorrectKYCLevel();

  bool registered = doubleName != null;

  await Flags().initialiseFlagSmith();
  await Flags().setFlagSmithDefaultValues();

  if(await getPhrase() != null) {
    await migrateToNewSystem();
  }

  runApp(MyApp(initDone: initDone, registered: registered));
}

Future<void> migrateToNewSystem() async {
  Map<String, dynamic> keyPair = await generateKeyPairFromSeedPhrase(await getPhrase());
  var client = FlutterPkid(pkidUrl, keyPair);

  await saveEmailToPKid(client, keyPair);
  await savePhoneToPKid(client, keyPair);

}

Future<void> saveEmailToPKid(FlutterPkid client, Map<String, dynamic> keyPair) async {
  Map<String, Object> email = await getEmail();
  var emailPKidResult = await client.getPKidDoc('email', keyPair);
  if(!emailPKidResult.containsKey('success') && email['email'] != null){
    if(email['sei'] != null) {
      return client.setPKidDoc('email', json.encode({'email': email['email'], 'sei' : email['sei'] }), keyPair);
    }

    if(email['email'] != null){
      return client.setPKidDoc('email', json.encode({'email': email }), keyPair);
    }
  }
}

Future<void> savePhoneToPKid(FlutterPkid client, Map<String, dynamic> keyPair) async {
  Map<String, Object> phone = await getPhone();
  var phonePKidResult = await client.getPKidDoc('phone', keyPair);
  if(!phonePKidResult.containsKey('success') && phone['phone'] != null){
    if(phone['spi'] != null) {
      return client.setPKidDoc('phone', json.encode({'phone': phone['phone'], 'spi' : phone['spi'] }), keyPair);
    }

    if(phone['phone'] != null){
      return client.setPKidDoc('phone', json.encode({'phone': phone }), keyPair);
    }
  }
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