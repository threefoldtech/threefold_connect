import 'package:flutter/material.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;
  ThemeProvider(this._themeMode);
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    await setTheme(_themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> _loadTheme() async {
    String? theme = await getTheme();
    _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
