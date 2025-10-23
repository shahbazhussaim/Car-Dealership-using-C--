import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF8B4513); // SaddleBrown
  static const Color secondary = Color(0xFFFAEBD7); // AntiqueWhite / beige

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
      background: const Color(0xFFFFFBF5),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFFFBF5),
    cardTheme: CardThemeData(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0.5,
      foregroundColor: primary,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, height: 1.3),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondary.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: Colors.brown,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
