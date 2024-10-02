import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/screens/splash_screen.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:threebotlogin/widgets/theme_provider.dart';
import 'package:threebotlogin/widgets/wizard/terms_agreement.dart';

extension ColorSchemeExtension on ColorScheme {
  Color get warning => brightness == Brightness.light
      ? const Color.fromARGB(255, 128, 102, 0)
      : const Color.fromARGB(255, 255, 204, 0);

  Color get onWarning => brightness == Brightness.light
      ? const Color.fromARGB(255, 255, 204, 0)
      : const Color.fromARGB(255, 64, 51, 0);

  Color get warningContainer => brightness == Brightness.light
      ? const Color.fromARGB(255, 255, 204, 0).withOpacity(0.3)
      : const Color.fromARGB(64, 255, 204, 0);

  Color get onWarningContainer => brightness == Brightness.light
      ? const Color.fromARGB(255, 64, 51, 0)
      : const Color.fromARGB(255, 255, 204, 0);

  Color get backgroundDarker => brightness == Brightness.light
      ? const Color.fromARGB(255, 240, 240, 240)
      : const Color.fromARGB(255, 10, 10, 10);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  bool initDone = await getInitDone();
  String? doubleName = await getDoubleName();

  await setGlobalValues();

  bool registered = doubleName != null;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => ThemeProvider()), // Theme provider
        ChangeNotifierProvider(
            create: (context) => TermsAgreement()), // Terms agreement provider
      ],
      child: MyApp(initDone: initDone, registered: registered),
    ),
  );
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

class MyApp extends StatefulWidget {
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
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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

    return MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        brightness: Brightness.light,
        textTheme: textTheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.primary,
          foregroundColor: kColorScheme.onPrimary,
        ),
        cardTheme: const CardTheme().copyWith(
            color: kColorScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              backgroundColor: kColorScheme.primaryContainer),
        ),
        expansionTileTheme: const ExpansionTileThemeData().copyWith(
            backgroundColor: kColorScheme.backgroundDarker,
            collapsedBackgroundColor: ThemeData().colorScheme.background),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
          selectedItemColor: kColorScheme.primary,
          unselectedItemColor: kColorScheme.secondary,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: kDarkColorScheme,
        brightness: Brightness.dark,
        textTheme: textTheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kDarkColorScheme.primaryContainer,
          foregroundColor: kDarkColorScheme.onPrimaryContainer,
        ),
        cardTheme: const CardTheme().copyWith(
            color: kDarkColorScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              backgroundColor: kDarkColorScheme.primaryContainer),
        ),
        expansionTileTheme: const ExpansionTileThemeData().copyWith(
            backgroundColor: kDarkColorScheme.backgroundDarker,
            collapsedBackgroundColor: kDarkColorScheme.background),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
          selectedItemColor: kDarkColorScheme.primary,
          unselectedItemColor: kDarkColorScheme.secondary,
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: SplashScreen(
          initDone: widget.initDone, registered: widget.registered),
    );
  }
}
