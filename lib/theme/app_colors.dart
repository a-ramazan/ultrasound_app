import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0E8F93);
  static const Color primaryDark = Color(0xFF0B5E73);
  static const Color accent = Color(0xFF54C7C3);
  static const Color deepNavy = Color(0xFF0C1B33);
  static const Color surface = Color(0xFFF4F9FC);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF10233B);
  static const Color textSecondary = Color(0xFF648097);
  static const Color success = Color(0xFF1B9C73);
  static const Color warning = Color(0xFFFFB648);

  static const LinearGradient pageGradient = LinearGradient(
    colors: [Color(0xFFE7F7F8), Color(0xFFF7FBFD), Color(0xFFE9F1FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF123C69), Color(0xFF0E8F93), Color(0xFF57CBC7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
