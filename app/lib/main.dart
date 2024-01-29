import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/screens/main_screen.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:google_fonts/google_fonts.dart';

extension ColorSchemeExtension on ColorScheme {
  Color get warning => brightness == Brightness.light
      ? const Color.fromARGB(255, 255, 208, 0)
      : const Color.fromARGB(255, 255, 219, 61);
}

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
  Globals().identityVerified.value =
      (identity['signedIdentityNameIdentifier'] != null);
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initDone,
    this.doubleName,
    required this.registered,
  });

  final bool initDone;
  final String? doubleName;
  final bool registered;

  @override
  Widget build(BuildContext context) {
    var kColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: const Color.fromARGB(255, 26, 161, 143),
    );

    var kDarkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color.fromARGB(255, 26, 161, 143),
    );
    var textTheme = GoogleFonts.latoTextTheme(
      Theme.of(context).textTheme,
    );

    var accentTextStyle = GoogleFonts.lato(
      textStyle: Theme.of(context).appBarTheme.titleTextStyle,
    );

    var textStyle = GoogleFonts.lato();
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: kColorScheme,
        brightness: Brightness.light,
        textTheme: textTheme,
        tabBarTheme:
            TabBarTheme(labelStyle: textStyle, unselectedLabelStyle: textStyle),
        appBarTheme: AppBarTheme(
          color: kColorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: accentTextStyle,
          toolbarTextStyle: accentTextStyle,
        ),
        cardTheme: const CardTheme().copyWith(
            color: kColorScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: kColorScheme.primaryContainer),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: kDarkColorScheme,
        brightness: Brightness.dark,
        textTheme: textTheme,
        tabBarTheme:
            TabBarTheme(labelStyle: textStyle, unselectedLabelStyle: textStyle),
        appBarTheme: AppBarTheme(
          color: kColorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: accentTextStyle,
          toolbarTextStyle: accentTextStyle,
        ),
        cardTheme: const CardTheme().copyWith(
            color: kDarkColorScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: kDarkColorScheme.primaryContainer),
        ),
      ),
      themeMode: ThemeMode.system,
      home: MainScreen(initDone: initDone, registered: registered),
    );
  }
}
