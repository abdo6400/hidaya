import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFF9F3EA); // ivory background
  static const Color secondaryColor = Color(0xFFD4AF37); // gold (from text/crescent)
  static const Color accentColor = Color(0xFF6B4F2C); // brown (book outline)
  static const Color backgroundColor = Color(0xFFFFFFFF); // pure white
  static const Color textColor = Color(0xFF2C2C2C); // dark gray for readability

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: secondaryColor,
      secondary: accentColor,
      background: backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      titleLarge: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
  );
}
