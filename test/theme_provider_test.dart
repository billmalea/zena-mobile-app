import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zena_mobile/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    late SharedPreferences prefs;
    late ThemeProvider themeProvider;

    setUp(() async {
      // Initialize SharedPreferences with mock
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      themeProvider = ThemeProvider(prefs);
    });

    test('should initialize with system theme mode by default', () {
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.isDarkMode, false);
    });

    test('should set theme mode to light', () async {
      await themeProvider.setThemeMode(ThemeMode.light);
      
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDarkMode, false);
      
      // Verify persistence
      final savedMode = prefs.getString('theme_mode');
      expect(savedMode, ThemeMode.light.toString());
    });

    test('should set theme mode to dark', () async {
      await themeProvider.setThemeMode(ThemeMode.dark);
      
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);
      
      // Verify persistence
      final savedMode = prefs.getString('theme_mode');
      expect(savedMode, ThemeMode.dark.toString());
    });

    test('should toggle theme from light to dark', () async {
      await themeProvider.setThemeMode(ThemeMode.light);
      await themeProvider.toggleTheme();
      
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);
    });

    test('should toggle theme from dark to light', () async {
      await themeProvider.setThemeMode(ThemeMode.dark);
      await themeProvider.toggleTheme();
      
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDarkMode, false);
    });

    test('should toggle theme from system to light', () async {
      await themeProvider.setThemeMode(ThemeMode.system);
      await themeProvider.toggleTheme();
      
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDarkMode, false);
    });

    test('should load saved theme mode from SharedPreferences', () async {
      // Save a theme mode
      await prefs.setString('theme_mode', ThemeMode.dark.toString());
      
      // Create new provider instance (simulates app restart)
      final newProvider = ThemeProvider(prefs);
      
      // Wait for async load to complete
      await Future.delayed(Duration.zero);
      
      expect(newProvider.themeMode, ThemeMode.dark);
      expect(newProvider.isDarkMode, true);
    });

    test('should persist theme mode changes', () async {
      await themeProvider.setThemeMode(ThemeMode.dark);
      
      // Create new provider instance (simulates app restart)
      final newProvider = ThemeProvider(prefs);
      
      // Wait for async load to complete
      await Future.delayed(Duration.zero);
      
      expect(newProvider.themeMode, ThemeMode.dark);
    });

    test('should notify listeners when theme mode changes', () async {
      var notified = false;
      themeProvider.addListener(() {
        notified = true;
      });
      
      await themeProvider.setThemeMode(ThemeMode.dark);
      
      expect(notified, true);
    });

    test('should handle invalid saved theme mode gracefully', () async {
      // Save invalid theme mode
      await prefs.setString('theme_mode', 'invalid_mode');
      
      // Create new provider instance
      final newProvider = ThemeProvider(prefs);
      
      // Wait for async load to complete
      await Future.delayed(Duration.zero);
      
      // Should default to system mode
      expect(newProvider.themeMode, ThemeMode.system);
    });
  });
}
