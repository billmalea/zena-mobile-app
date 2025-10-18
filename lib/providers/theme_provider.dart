import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme (light/dark/system)
/// 
/// Handles theme mode persistence and switching between light, dark, and system themes.
/// Theme preference is saved to SharedPreferences and loaded on app start.
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider(this._prefs) {
    _loadThemeMode();
  }
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Whether dark mode is currently active
  /// Returns true if theme mode is explicitly set to dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Load saved theme mode from SharedPreferences
  void _loadThemeMode() {
    final savedMode = _prefs.getString(_themeKey);
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedMode,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }
  
  /// Set theme mode and persist to SharedPreferences
  /// 
  /// [mode] The theme mode to set (light, dark, or system)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }
  
  /// Toggle between light and dark theme
  /// 
  /// If current mode is system, switches to light.
  /// If current mode is light, switches to dark.
  /// If current mode is dark, switches to light.
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
      ? ThemeMode.dark 
      : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
