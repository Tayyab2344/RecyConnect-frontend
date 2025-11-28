import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Initialize theme from saved preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isDarkMode = await PreferencesService.getDarkMode();
    _isInitialized = true;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    await PreferencesService.saveDarkMode(_isDarkMode);
  }
}
