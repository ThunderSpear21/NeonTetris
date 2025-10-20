import 'package:flutter/material.dart';
import 'package:neon_tetris_frontend/theme/app_colours.dart';

class AppTheme {
  // Define light theme using ColorScheme.fromSeed
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.lightSeed,
    brightness: Brightness.light,
  );

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    fontFamily: 'Orbitron',
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: _lightColorScheme.onSurface),
      bodyMedium: TextStyle(color: _lightColorScheme.onSurface),
      bodySmall: TextStyle(color: _lightColorScheme.onSurface),
      labelLarge: TextStyle(color: _lightColorScheme.onSurface),
      labelMedium: TextStyle(color: _lightColorScheme.onSurface),
      labelSmall: TextStyle(color: _lightColorScheme.onSurface),
      displayLarge: TextStyle(color: _lightColorScheme.onSurface),
      displayMedium: TextStyle(color: _lightColorScheme.onSurface),
      displaySmall: TextStyle(color: _lightColorScheme.onSurface),
      headlineLarge: TextStyle(color: _lightColorScheme.onSurface),
      headlineMedium: TextStyle(color: _lightColorScheme.onSurface),
      headlineSmall: TextStyle(color: _lightColorScheme.onSurface),
      titleLarge: TextStyle(color: _lightColorScheme.onSurface),
      titleMedium: TextStyle(color: _lightColorScheme.onSurface),
      titleSmall: TextStyle(color: _lightColorScheme.onSurface),
    ),
    scaffoldBackgroundColor: Color.fromARGB(255, 255, 40, 40).withValues(alpha: 0.15),
    // scaffoldBackgroundColor: _lightColorScheme.surface,
    cardColor: _lightColorScheme.surface,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: _lightColorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightColorScheme.primary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        elevation: 2,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
    ),
  );

  // Define dark theme using ColorScheme.fromSeed
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.darkSeed,
    brightness: Brightness.dark,
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    fontFamily: 'Orbitron',
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: _darkColorScheme.onSurface),
      bodyMedium: TextStyle(color: _darkColorScheme.onSurface),
      bodySmall: TextStyle(color: _darkColorScheme.onSurface),
      displaySmall: TextStyle(color: _darkColorScheme.onSurface),
      displayMedium: TextStyle(color: _darkColorScheme.onSurface),
      displayLarge: TextStyle(color: _darkColorScheme.onSurface),
      labelSmall: TextStyle(color: _darkColorScheme.onSurface),
      labelMedium: TextStyle(color: _darkColorScheme.onSurface),
      labelLarge: TextStyle(color: _darkColorScheme.onSurface),
      headlineLarge: TextStyle(color: _darkColorScheme.onSurface),
      headlineSmall: TextStyle(color: _darkColorScheme.onSurface),
      headlineMedium: TextStyle(color: _darkColorScheme.onSurface),
      titleSmall: TextStyle(color: _darkColorScheme.onSurface),
      titleLarge: TextStyle(color: _darkColorScheme.onSurface),
      titleMedium: TextStyle(color: _darkColorScheme.onSurface),
    ),
    scaffoldBackgroundColor: _darkColorScheme.surface,
    cardColor: _darkColorScheme.surface,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: _darkColorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkColorScheme.primary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        elevation: 2,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
    ),
  );
}
