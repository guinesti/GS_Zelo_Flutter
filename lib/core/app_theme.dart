import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaria = Color(0xFF0E7C66);
  static const Color destaque = Color(0xFFF5A623);
  static const Color fundo = Color(0xFFF6F8F7);

  static const Color prioridadeAlta = Color(0xFFD64545);
  static const Color prioridadeMedia = Color(0xFFE59A1A);
  static const Color prioridadeBaixa = Color(0xFF3A8D5C);
}

class AppTheme {
  AppTheme._();

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppColors.primaria,
      primary: AppColors.primaria,
      secondary: AppColors.destaque,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColors.fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaria,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaria,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaria,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class Espacos {
  Espacos._();

  static const double p = 8;
  static const double m = 16;
  static const double g = 24;
}
