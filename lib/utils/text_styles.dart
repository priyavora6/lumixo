import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const String fontFamily = 'serif';

  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle appName = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: 3,
  );

  static const TextStyle tagline = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    color: AppColors.textMedium,
    letterSpacing: 2,
  );
}