import 'package:flutter/material.dart';

class AppColors {
  // Stitch Design System Palette
  static const Color primary = Color(0xFF13C8EC); // Cyan
  static const Color primaryDark = Color(0xFF0EBCD9);
  
  static const Color backgroundDark = Color(0xFF101F22); // Deep Dark Teal/Black
  static const Color backgroundLight = Color(0xFFF6F8F8);
  
  static const Color surfaceDark = Color(0xFF1A2C30);
  static const Color surfaceDarker = Color(0xFF0D1517);
  static const Color surfaceLight = Colors.white;

  static const Color textWhite = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
}

enum DotStyle { round, square }

class AppTheme {
  final String id;
  final String name;
  final Color background;
  final Color surface;
  final Color dotPassed;
  final Color dotToday;
  final Color dotFuture;
  final Color textPrimary;
  final Color textSecondary;
  final DotStyle dotStyle;
  final bool showText;

  const AppTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.dotPassed,
    required this.dotToday,
    required this.dotFuture,
    required this.textPrimary,
    required this.textSecondary,
    this.dotStyle = DotStyle.round,
    this.showText = true,
  });

  factory AppTheme.fromId(String id) {
    return themes.firstWhere((t) => t.id == id, orElse: () => defaults);
  }

  // Default "Stitch" Theme (Midnight)
  static const AppTheme defaults = AppTheme(
    id: 'default',
    name: 'Default',
    background: Color(0xFF0F172A), // Slate 900
    surface: AppColors.surfaceDark,
    dotPassed: Color(0x66FFFFFF),   // White 40%
    dotToday: AppColors.primary,
    dotFuture: Color(0x1AFFFFFF),   // White 10%
    textPrimary: Colors.white,
    textSecondary: Color(0xFF94A3B8), // Slate 400
    dotStyle: DotStyle.round,
    showText: true,
  );

  static const List<AppTheme> themes = [defaults];
}
