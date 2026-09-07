import 'package:flutter/material.dart';

/// Mobin X Cyberpunk & High-Density Dark Gamer Color Palette
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF070D19);
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceCard = Color(0xFF131D31);
  static const Color surfaceCardHover = Color(0xFF1E293B);
  static const Color surfaceInput = Color(0xFF0A1120);

  // Borders & Dividers
  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFF334155);
  static const Color borderGlow = Color(0xFF38BDF8);

  // Brand Gradients & Accents
  static const Color primary = Color(0xFF2563EB); // Electric Royal Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color cyan = Color(0xFF06B6D4); // Cyber Cyan
  static const Color cyanLight = Color(0xFF38BDF8);
  static const Color gold = Color(0xFFF59E0B); // Amber Gold
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color emerald = Color(0xFF10B981); // Emerald Green
  static const Color danger = Color(0xFFEF4444); // Crimson Rose
  static const Color purple = Color(0xFF8B5CF6); // Neon Purple

  // Text Colors
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF64748B);

  // Linear Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gamerGlowGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
