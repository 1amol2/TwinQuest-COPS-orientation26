import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.red,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.text,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          color: AppColors.text,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
        ),
        headlineSmall: TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: AppColors.text,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.text,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSoft,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amber,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        error: AppColors.red,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          color: AppColors.darkText,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
        ),
        headlineSmall: TextStyle(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkText,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: AppColors.darkTextSoft,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: TextStyle(
          color: AppColors.darkMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.darkText),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
