import 'package:flutter/material.dart';

class AppColors {
  // ─── PRIMARY ──────────────────────────────────────
  static const Color primary = Color(0xFFE8A0B4);
  static const Color secondary = Color(0xFFB5D5A8);

  // ─── BACKGROUND ───────────────────────────────────
  static const Color background = Color(0xFFFDF6FF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // ─── GRADIENT COLORS ──────────────────────────────
  static const Color gradientStart = Color(0xFFB8D4F0);
  static const Color gradientMid = Color(0xFFD4B8F0);
  static const Color gradientEnd = Color(0xFFF0B8D4);

  // ─── TEXT ─────────────────────────────────────────
  static const Color textDark = Color(0xFF3D2C4E);
  static const Color textMedium = Color(0xFF7A6A8A);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color lightGrey = Color(0xFFD3D3D3);

  // ─── THESE WERE ALREADY IN YOUR FILE ──────────────
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color coinColor = Color(0xFFFFB830);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF6BCB77);

  // ════════════════════════════════════════════════
  // ✅ NEWLY ADDED — fixes all prompt_detail errors
  // ════════════════════════════════════════════════

  // AppColors.success  → line 32, 47
  static const Color success = Color(0xFF6BCB77);

  // AppColors.error  → used in border color
  static const Color error = Color(0xFFFF6B6B);

  // AppColors.accent  → line 102 (favorite heart)
  static const Color accent = Color(0xFFFF6B9D);

  // AppColors.info  → line 158 (AI model chip)
  static const Color info = Color(0xFF64B5F6);

  // AppColors.warning  → line 160 (aspect ratio chip)
  static const Color warning = Color(0xFFFFB830);

  // AppColors.textWhite  → line 128, 191
  static const Color textWhite = Colors.white;

  // AppColors.textGray  → tag text, prompt text
  static const Color textGray = Color(0xFF9E9E9E);

  // AppColors.bgDark  → line 60, 67, 76, 91
  static const Color bgDark = Color(0xFF1A1A2E);

  // AppColors.bgCard  → line 204 (card bg)
  static const Color bgCard = Color(0xFF16213E);

  // AppColors.bgCardLight  → line 206 (card border)
  static const Color bgCardLight = Color(0xFF0F3460);

  // ─── GRADIENTS ────────────────────────────────────
  static const LinearGradient backgroundGradient =
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFC8DFF5),
      Color(0xFFD4C8F5),
      Color(0xFFE8C8F0),
      Color(0xFFF0C8D8),
    ],
  );

  static const LinearGradient primaryGradient =
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8A0B4),
      Color(0xFFB8A0E8),
    ],
  );

  static const LinearGradient premiumGradient =
  LinearGradient(
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFFB830),
    ],
  );
}