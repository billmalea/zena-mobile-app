import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme configuration
/// Matches the web design with Emerald/Teal color scheme
class AppTheme {
  // Primary Colors (Emerald/Teal)
  static const Color primaryColor = Color(0xFF10B981); // Emerald-500
  static const Color primaryLight = Color(0xFF34D399); // Emerald-400
  static const Color primaryDark = Color(0xFF059669); // Emerald-600

  static const Color secondaryColor = Color(0xFF14B8A6); // Teal-500
  static const Color secondaryLight = Color(0xFF2DD4BF); // Teal-400
  static const Color secondaryDark = Color(0xFF0D9488); // Teal-600

  // Background Colors
  static const Color backgroundColor = Color(0xFFFAFAFA); // Faded white
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color cardColor = Color(0xFFFFFFFF); // White

  // Text Colors - Faded Black Scheme
  static const Color textPrimary =
      Color(0xFF0A0A0A); // Faded black (primary text)
  static const Color textSecondary =
      Color(0xFF404040); // Faded black (secondary text)
  static const Color textTertiary =
      Color(0xFF737373); // Faded black (tertiary text)

  // Message Bubble Colors
  static const Color userMessageBg = Color(0xFF10B981); // Emerald-500
  static const Color userMessageText = Color(0xFFFFFFFF); // White
  static const Color assistantMessageBg = Color(0xFFFFFFFF); // White
  static const Color assistantMessageText = Color(0xFF111827); // Gray-900

  // Status Colors
  static const Color errorColor = Color(0xFFEF4444); // Red-500
  static const Color successColor = Color(0xFF10B981); // Emerald-500
  static const Color warningColor = Color(0xFFF59E0B); // Amber-500
  static const Color infoColor = Color(0xFF3B82F6); // Blue-500

  // Border Colors
  static const Color borderColor = Color(0xFFE5E7EB); // Gray-200
  static const Color dividerColor = Color(0xFFE5E7EB); // Gray-200

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryLight,
        secondary: secondaryColor,
        secondaryContainer: secondaryLight,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
      ),

      // Card Theme
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: errorColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Dark theme configuration (optional, for future enhancement)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor:const Color.fromARGB(255, 10, 10, 10) ,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Color.fromARGB(255, 10, 10, 10),
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }
}
