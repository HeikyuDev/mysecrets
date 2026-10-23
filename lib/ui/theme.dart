import 'package:flutter/material.dart';

class AppTheme {
  static const accent = Color(0xFF4CC9F0);
  static const accentAlt = Color(0xFF90F1EF);
  static const bg = Color(0xFF0D1B2A);
  static const surface = Color(0xFF142840);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: accentAlt,
        surface: surface,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: bg,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}
