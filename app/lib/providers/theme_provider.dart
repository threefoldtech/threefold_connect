import 'package:flutter/material.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveTheme();
  }

  Future<void> _saveTheme() async {
    await setTheme(state == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> loadTheme() async {
    String? savedTheme = await getTheme();
    if (savedTheme != null) {
      state = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }
}

final themeModeNotifier =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
        (ref) => ThemeModeNotifier());

