import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Thèmes Material 3 de l'application (clair et sombre).
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.deepPurple,
      brightness: Brightness.light,
      primary: AppColors.deepPurple,
      secondary: AppColors.gold,
      surface: Colors.white,
      surfaceContainerLowest: AppColors.creamBackground,
      onPrimary: Colors.white,
      onSecondary: AppColors.deepPurple,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.textSecondary,
      outlineVariant: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Amiri',
      scaffoldBackgroundColor: AppColors.creamBackground, // cream page bg
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.creamBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      textTheme: _buildTextTheme(AppColors.textPrimary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.deepPurple,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.mediumPurple,
      brightness: Brightness.dark,
      primary: AppColors.lightPurple,
      secondary: AppColors.gold,
      surface: AppColors.darkSurface,              // Cards / containers
      surfaceContainerLowest: AppColors.darkCard,  // Elevated inner containers
      onPrimary: AppColors.darkBackground,
      onSecondary: AppColors.darkBackground,
      onSurface: AppColors.textOnDark,
      onSurfaceVariant: AppColors.mediumPurple,
      outline: AppColors.mediumPurple,
      outlineVariant: AppColors.darkCard,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Amiri',
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkSurface, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mediumPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPurple,
          side: const BorderSide(color: AppColors.lightPurple),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkSurface, thickness: 1),
      textTheme: _buildTextTheme(AppColors.textOnDark),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.lightPurple,
        textColor: AppColors.textOnDark,
        subtitleTextStyle: TextStyle(color: AppColors.mediumPurple, fontSize: 13),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.lightPurple,
        unselectedLabelColor: AppColors.mediumPurple,
        indicatorColor: AppColors.lightPurple,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: AppColors.lightPurple,
        collapsedIconColor: AppColors.lightPurple,
        textColor: AppColors.textOnDark,
        collapsedTextColor: AppColors.textOnDark,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.darkSurface),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.lightPurple,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.lightPurple
                : AppColors.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.lightPurple.withValues(alpha: 0.4)
                : AppColors.darkSurface),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.lightPurple,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
      displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
      headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: color),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: color),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: color.withValues(alpha: 0.7)),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
    );
  }
}
