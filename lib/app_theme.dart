import 'package:flutter/material.dart';
import 'utils/constants.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.secondary.withOpacity(0.15),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.primary,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: const CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimens.cardRadius)),
      ),
      elevation: 2,
      margin: EdgeInsets.all(AppDimens.padding),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.brown.shade900,
      displayColor: Colors.brown.shade900,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      color: WidgetStateProperty.all(AppColors.secondary),
      labelStyle: TextStyle(color: Colors.brown.shade800),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
