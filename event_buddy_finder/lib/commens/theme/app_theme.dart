import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors inspired by event & social apps:
  static const Color primaryColor = Color(0xFF0052CC);    // Bright Blue (trust, action)
  static const Color secondaryColor = Color(0xFFFF7043);  // Warm Orange (energy, excitement)
  static const Color accentColor = Color(0xFF00C853);     // Vibrant Green (growth, success)
  static const Color backgroundLight = Color(0xFFF9FAFB); // Soft Off-white for Light bg
  static const Color backgroundDark = Color(0xFF121212);  // Dark bg for Night mode
  static const Color surfaceDark = Color(0xFF1E1E1E);     // Cards and surfaces in dark mode

  static const Color textLightPrimary = Color(0xFF202124); // Dark Gray (near black)
  static const Color textLightSecondary = Color(0xFF5F6368); // Medium Gray for subtitles/text
  static const Color textDarkPrimary = Color(0xFFE8EAED);  // Light Gray for dark mode
  static const Color textDarkSecondary = Color(0xFF9AA0A6); // Medium Gray for dark mode

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundLight,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textLightPrimary,
      onSurface: textLightPrimary,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: textLightPrimary,
      displayColor: textLightPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryColor,
      elevation: 1,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor),
      iconTheme: const IconThemeData(color: primaryColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: textLightSecondary),
      hintStyle: TextStyle(color: textLightSecondary.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textLightSecondary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.4),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.08),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dividerColor: textLightSecondary.withOpacity(0.3),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundDark,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textDarkPrimary,
      onSurface: textDarkPrimary,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: textDarkPrimary,
      displayColor: textDarkPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor),
      iconTheme: const IconThemeData(color: primaryColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      labelStyle: TextStyle(color: textDarkSecondary),
      hintStyle: TextStyle(color: textDarkSecondary.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textDarkSecondary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: primaryColor.withOpacity(0.7),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surfaceDark,
      shadowColor: Colors.black.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dividerColor: textDarkSecondary.withOpacity(0.3),
  );
}
