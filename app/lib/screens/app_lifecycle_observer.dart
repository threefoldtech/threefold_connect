import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/screens/home_screen.dart';

class AppLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;
  const AppLifecycleObserver({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver>
    with WidgetsBindingObserver {
  final int pinCheckTimeout = 60000 * 5; // 5 minute

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(lastPausedProvider.notifier).state =
          DateTime.now().millisecondsSinceEpoch;
    });
    logger.i('AppLifecycleObserver initialized.');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    logger.i('AppLifecycleObserver disposed.');
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    logger.i('AppLifecycleState changed: $state');

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastPaused = ref.read(lastPausedProvider);

    if (state == AppLifecycleState.paused) {
      ref.read(lastPausedProvider.notifier).state = now;
      logger.i('App Paused. Last paused time updated: $now');
    } else if (state == AppLifecycleState.resumed) {
      if (now - lastPaused >= pinCheckTimeout) {
        logger.i('Timeout expired. Requiring authentication.');
        // Navigate to Home Screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
        ref.read(lastPausedProvider.notifier).state = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
