import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/screens/app_lifecycle_observer.dart';
import 'package:threebotlogin/screens/splash_screen.dart';
import 'package:threebotlogin/services/background_service.dart';
import 'package:threebotlogin/services/notification_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:threebotlogin/providers/theme_provider.dart';

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

Color _blendColors(Color base, Color tint, double ratio) {
  return Color.lerp(base, tint, ratio) ?? base;
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final lastPausedProvider =
    StateProvider<int>((ref) => DateTime.now().millisecondsSinceEpoch);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await NotificationService().initNotification();

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  bool initDone = await getInitDone();
  String? doubleName = await getDoubleName();

  await setGlobalValues();
  bool registered = doubleName != null;

  runApp(
    ProviderScope(
      child: MyApp(initDone: initDone, registered: registered),
    ),
  );

  BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: false,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiredNetworkType: NetworkType.ANY,
    ),
    (String taskId) async {
      logger.i('[BackgroundFetch] Task: $taskId');
      await checkNodeStatus(taskId);
      BackgroundFetch.finish(taskId);
    },
    (String taskId) async {
      logger.i('[BackgroundFetch] Timeout: $taskId');
      BackgroundFetch.finish(taskId);
    },
  );
}

Future<void> setGlobalValues() async {
  Map<String, String?> email = await getEmail();
  Map<String, String?> phone = await getPhone();

  Globals().emailVerified.value = (email['sei'] != null);
  Globals().phoneVerified.value = (phone['spi'] != null);
}

class MyApp extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(themeModeNotifier.notifier).loadTheme();
    final themeMode = ref.watch(themeModeNotifier);
    var kColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: const Color.fromARGB(255, 26, 161, 143),
    );
    
    kColorScheme = kColorScheme.copyWith(
      primaryContainer: _blendColors(
        kColorScheme.surfaceContainer,
        kColorScheme.primary,
        0.08,
      ),
      onPrimaryContainer: kColorScheme.primary,
    );

    var kDarkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color.fromARGB(255, 26, 161, 143),
    );
    var textTheme = GoogleFonts.latoTextTheme(
      Theme.of(context).textTheme,
    );

    return AppLifecycleObserver(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(
          useMaterial3: true,
        ).copyWith(
          colorScheme: kColorScheme,
          brightness: Brightness.light,
          scaffoldBackgroundColor: kColorScheme.surfaceContainerHighest,
          textTheme: textTheme,
          appBarTheme: const AppBarTheme().copyWith(
            backgroundColor: kColorScheme.surfaceContainerHighest,
            foregroundColor: kColorScheme.onSurface,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
              color: kColorScheme.surfaceContainer,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: kColorScheme.primaryContainer,
                foregroundColor: kColorScheme.onPrimaryContainer),
          ),
          expansionTileTheme: const ExpansionTileThemeData().copyWith(
              backgroundColor: kColorScheme.surfaceContainerHighest,
              collapsedBackgroundColor: kColorScheme.surfaceContainerHighest),
          bottomNavigationBarTheme:
              const BottomNavigationBarThemeData().copyWith(
            backgroundColor: kColorScheme.surfaceContainerHighest,
            selectedItemColor: kColorScheme.primary,
            unselectedItemColor: kColorScheme.secondary,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: kDarkColorScheme,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: kDarkColorScheme.surfaceContainerHighest,
          textTheme: textTheme,
          appBarTheme: const AppBarTheme().copyWith(
            backgroundColor: kDarkColorScheme.surfaceContainerHighest,
            foregroundColor: kDarkColorScheme.onSurface,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
              color: kDarkColorScheme.surfaceContainer,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: kDarkColorScheme.primaryContainer,
                foregroundColor: kDarkColorScheme.onPrimaryContainer),
          ),
          expansionTileTheme: const ExpansionTileThemeData().copyWith(
              backgroundColor: kDarkColorScheme.surfaceContainerHighest,
              collapsedBackgroundColor: kDarkColorScheme.surfaceContainerHighest),
          bottomNavigationBarTheme:
              const BottomNavigationBarThemeData().copyWith(
            backgroundColor: kDarkColorScheme.surfaceContainerHighest,
            selectedItemColor: kDarkColorScheme.primary,
            unselectedItemColor: kDarkColorScheme.secondary,
            elevation: 0,
          ),
        ),
        themeMode: themeMode,
        home: SplashScreen(initDone: initDone, registered: registered),
      ),
    );
  }
}
