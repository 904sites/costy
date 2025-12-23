import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Matcha Greens
  static const Color matchaDark = Color(0xFF4A6644);
  static const Color matchaMedium = Color(0xFF9FAA74);
  static const Color matchaLight = Color(0xFFD7DAB3);

  // Strawberry Pinks
  static const Color strawberryDark = Color(0xFFC66F80);
  static const Color strawberryMedium = Color(0xFFF4C7D0);
  static const Color strawberryLight = Color(0xFFFCEBF1);

  // Neutral
  static const Color beigeBackground = Color(0xFFECE3D2);
  static const Color white = Colors.white;
}

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.beigeBackground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.matchaDark,
    primary: AppColors.matchaDark,
    secondary: AppColors.strawberryDark,
  ),
  // Font Pairing Implementation
  textTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      color: AppColors.matchaDark,
    ),
    titleLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: AppColors.matchaDark,
    ),
    bodyLarge: GoogleFonts.inter(fontSize: 16),
    bodyMedium: GoogleFonts.inter(fontSize: 14),
    labelLarge: GoogleFonts.inter(
      fontWeight: FontWeight.bold,
    ), // Untuk angka/tabel
  ),
);
