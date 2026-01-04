import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Blue Color (#4A90E2)
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color scaffoldBackgroundColor =
      Color(0xFFF5F7FA); // Light Grey-Blue for background

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        background: scaffoldBackgroundColor,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: GoogleFonts.kanitTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black, // Dark text for app bar
      ),
    );
  }
}
