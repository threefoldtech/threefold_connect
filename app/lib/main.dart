import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/screens/main_screen.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  bool initDone = await getInitDone();
  String? doubleName = await getDoubleName();

  await setGlobalValues();

  bool registered = doubleName != null;
  runApp(MyApp(initDone: initDone, registered: registered));
}

Future<void> setGlobalValues() async {
  Map<String, String?> email = await getEmail();
  Map<String, String?> phone = await getPhone();
  Map<String, dynamic> identity = await getIdentity();

  Globals().emailVerified.value = (email['sei'] != null);
  Globals().phoneVerified.value = (phone['spi'] != null);
  Globals().identityVerified.value = (identity['signedIdentityNameIdentifier'] != null);
}

class MyApp extends StatelessWidget {
  MyApp({required this.initDone, this.doubleName, required this.registered});

  final bool initDone;
  final String? doubleName;
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
        appBarTheme: AppBarTheme(
            color: Colors.white, textTheme: accentTextTheme, brightness: Brightness.dark),
      ),
      home: MainScreen(initDone: initDone, registered: registered),
    );
  }
}
