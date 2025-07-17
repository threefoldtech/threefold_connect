// Example of how to integrate F-Droid compatible background service in main.dart
// This shows the changes needed to migrate from background_fetch to the new service

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/screens/app_lifecycle_observer.dart';
import 'package:threebotlogin/screens/splash_screen.dart';
// OLD: import 'package:threebotlogin/services/background_service.dart';
import 'package:threebotlogin/services/f_droid_background_service.dart'; // NEW
import 'package:threebotlogin/services/notification_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:threebotlogin/providers/theme_provider.dart';

// Remove background_fetch import
// OLD: import 'package:background_fetch/background_fetch.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final lastPausedProvider =
    StateProvider<int>((ref) => DateTime.now().millisecondsSinceEpoch);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await NotificationService().initNotification();

  // OLD: BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  // NEW: Initialize F-Droid compatible background service
  try {
    await FDroidBackgroundService.initialize();
    logger.i('[Main] F-Droid background service initialized');
  } catch (e) {
    logger.e('[Main] Failed to initialize F-Droid background service: $e');
  }

  bool initDone = await getInitDone();
  
  // Start background tasks if notifications are enabled
  if (initDone) {
    try {
      await FDroidBackgroundService.startPeriodicTask();
      logger.i('[Main] Background tasks started');
    } catch (e) {
      logger.e('[Main] Failed to start background tasks: $e');
    }
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// Example of how to handle background service lifecycle in your app
class BackgroundServiceManager {
  static Future<void> startBackgroundService() async {
    try {
      await FDroidBackgroundService.initialize();
      await FDroidBackgroundService.startPeriodicTask();
      logger.i('[BackgroundServiceManager] Service started successfully');
    } catch (e) {
      logger.e('[BackgroundServiceManager] Failed to start service: $e');
    }
  }

  static Future<void> stopBackgroundService() async {
    try {
      await FDroidBackgroundService.stopPeriodicTask();
      logger.i('[BackgroundServiceManager] Service stopped successfully');
    } catch (e) {
      logger.e('[BackgroundServiceManager] Failed to stop service: $e');
    }
  }

  static Future<bool> isServiceEnabled() async {
    try {
      return await FDroidBackgroundService.isEnabled();
    } catch (e) {
      logger.e('[BackgroundServiceManager] Failed to check service status: $e');
      return false;
    }
  }
}

// Example of integrating with app lifecycle
class AppLifecycleManager extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        logger.i('[AppLifecycle] App resumed');
        // Optionally restart background service
        BackgroundServiceManager.startBackgroundService();
        break;
      case AppLifecycleState.paused:
        logger.i('[AppLifecycle] App paused');
        // Background service continues running
        break;
      case AppLifecycleState.detached:
        logger.i('[AppLifecycle] App detached');
        // Background service continues running
        break;
      case AppLifecycleState.inactive:
        logger.i('[AppLifecycle] App inactive');
        break;
      case AppLifecycleState.hidden:
        logger.i('[AppLifecycle] App hidden');
        break;
    }
  }
}

// Example MyApp class with proper background service integration
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'ThreeFold Connect',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      themeMode: themeMode,
      home: const SplashScreen(),
      builder: (context, child) {
        // Add lifecycle observer
        WidgetsBinding.instance.addObserver(AppLifecycleManager());
        return child!;
      },
    );
  }
}

/* 
MIGRATION STEPS:

1. Remove background_fetch dependency from pubspec.yaml
2. Add workmanager dependency
3. Update imports in main.dart
4. Replace BackgroundFetch.registerHeadlessTask with FDroidBackgroundService.initialize
5. Update any background service calls throughout the app
6. Test on both Android and iOS
7. Verify F-Droid compatibility

TESTING:
- Run `flutter clean && flutter pub get`
- Test on both platforms
- Verify background tasks work when app is backgrounded
- Check logs for proper initialization
*/
