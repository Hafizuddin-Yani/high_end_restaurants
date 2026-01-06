import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primaryGold = Color(0xFFD4AF37);
  static const Color _darkSlate = Color(0xFF1A1A1A);
  static const Color _charcoal = Color(0xFF2C2C2C);
  static const Color _offWhite = Color(0xFFF5F5F5);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _primaryGold,
      scaffoldBackgroundColor: _darkSlate,
      cardColor: _charcoal,
      colorScheme: const ColorScheme.dark(
        primary: _primaryGold,
        secondary: _primaryGold,
        surface: _charcoal,
        background: _darkSlate,
        onPrimary: _darkSlate,
        onSurface: _offWhite,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _primaryGold,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _offWhite,
        ),
        bodyLarge: GoogleFonts.lato(fontSize: 16, color: _offWhite),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: _offWhite.withOpacity(0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGold,
          foregroundColor: _darkSlate,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _charcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryGold),
        ),
        hintStyle: GoogleFonts.lato(color: _offWhite.withOpacity(0.5)),
      ),
    );
  }
}
