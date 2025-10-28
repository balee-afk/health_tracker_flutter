import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF6F8F7);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textSecondaryMuted = Color(0x9964748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color primaryGreenSoft = Color(0x2622C55E);
  static const Color primaryGreenFaint = Color(0x1A22C55E);
}

ThemeData buildAppTheme() {
  final baseText = GoogleFonts.poppinsTextTheme();
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
    ).copyWith(
      primary: AppColors.primaryGreen,
      surface: AppColors.card,
    ),
    textTheme: baseText.copyWith(
      bodyMedium: baseText.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
      bodySmall: baseText.bodySmall?.copyWith(
        color: AppColors.textSecondary,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen),
      ),
      filled: true,
      fillColor: Colors.white,
      hintStyle: baseText.bodyMedium?.copyWith(
        color: AppColors.textSecondaryMuted,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
