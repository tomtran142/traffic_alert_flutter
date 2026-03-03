import 'package:flutter/material.dart';

class AppTheme {
  static const primaryGreen = Color(0xFF27AE60);
  static const accentGreen = Color(0xFF2ECC71);
  static const alertRed = Color(0xFFE53935);
  static const bgLight = Color(0xFFF5F6F7);

  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen, primary: primaryGreen, error: alertRed, surface: Colors.white),
    useMaterial3: true,
    scaffoldBackgroundColor: bgLight,
  );
}
