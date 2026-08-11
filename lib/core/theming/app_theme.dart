import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.almaraiTextTheme(),
      fontFamily: GoogleFonts.almarai().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mainTeal,
        primary: AppColors.mainTeal,
        secondary: AppColors.primaryTeal,
        tertiary: AppColors.lightTeal,
        surface: AppColors.scaffoldBackground,
      ),
      scaffoldBackgroundColor: Colors.white,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.mainTeal),
      ),

    );
  }
}