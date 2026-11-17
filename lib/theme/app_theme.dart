import 'package:flutter/material.dart';

/// Calm Ocean palette.
/// 60%  mist   -> page backgrounds (white cards sit on top)
/// 30%  teal   -> headers, icons, selected pills
/// 10%  orange -> actions only (buttons), nothing else
class AppColors {
  static const mist = Color(0xFFEEF5F7);
  static const teal = Color(0xFF0E6E7E);
  static const tealMid = Color(0xFF14808F);
  static const tealLight = Color(0xFF1A93A4);
  static const tint = Color(0xFFD5E8EC);
  static const orange = Color(0xFFE4572E);
  static const ink = Color(0xFF1F2D30);
  static const muted = Color(0xFF5A6B70);
  static const heroText = Color(0xFFC4E4EA);
  static const success = Color(0xFF2E7D32);
  static const danger = Color(0xFFC62828);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    primary: AppColors.teal,
    secondary: AppColors.orange,
    surface: Colors.white,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.mist,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
  );
}
