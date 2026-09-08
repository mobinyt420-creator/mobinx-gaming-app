import 'package:flutter/material.dart';

/// Mobin X Enterprise Light & Vibrant Design System Tokens (Aligned with original website)
class AppColors {
  AppColors._();

  // Backgrounds & Surfaces (Original Light Palette)
  static const Color background = Color(0xFFF8FAFC); // Clean slate-50 background
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceCard = Color(0xFFFFFFFF); // Pure white card
  static const Color surfaceCardSubtle = Color(0xFFF1F5F9); // Subtle slate-100
  static const Color surfaceInput = Color(0xFFF8FAFC);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Subtle slate-200 border
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderFocus = Color(0xFF3B82F6);
  static const Color surfaceBorder = Color(0xFFE2E8F0);

  // Brand Palette
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF); // Light blue tint
  static const Color secondary = Color(0xFF7C3AED); // Royal Purple
  static const Color secondaryLight = Color(0xFFF5F3FF);
  static const Color purple = Color(0xFF7C3AED);

  // Accents & Semantics
  static const Color cyan = Color(0xFF00D2FF); // Cyan
  static const Color cyanLight = Color(0xFF38BDF8);
  static const Color gold = Color(0xFFF59E0B); // Amber Gold
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color emerald = Color(0xFF10B981); // Emerald Green
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B);

  // Typography
  static const Color textMain = Color(0xFF0F172A); // Slate-900 high contrast
  static const Color textBody = Color(0xFF334155); // Slate-700
  static const Color textSecondary = Color(0xFF475569); // Slate-600
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400
  static const Color textDisabled = Color(0xFFCBD5E1);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF00D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gamerGlowGradient = brandGradient;

  static const LinearGradient heroPurpleGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient flashBannerGradient = LinearGradient(
    colors: [Color(0xFF090D16), Color(0xFF172554)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient telegramGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
