import 'package:flutter/material.dart';

/// Palet warna eksklusif bertema Romantic Dark Luxury sesuai SRS NFR-PORT-01
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF090813);
  static const Color surface = Color(0xFF141026);
  static const Color surfaceCard = Color(0xFF1E1738);
  static const Color surfaceGlass = Color(0x991E1738);
  static const Color surfaceElevated = Color(0xFF28204A);

  // Romantic Brand Accents
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color primaryRose = Color(0xFFF43F5E);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Gradients
  static const LinearGradient romanticGradient = LinearGradient(
    colors: [primaryPink, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1E1738), Color(0xFF141026)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [Color(0x40EC4899), Color(0x408B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHighlight = Color(0xFFF472B6);

  // Status & Presence Indicators (SRS FR-AUTH-02)
  static const Color onlineGreen = Color(0xFF22C55E);
  static const Color offlineGrey = Color(0xFF64748B);
  static const Color typingPink = Color(0xFFEC4899);

  // Borders
  static const Color borderSubtle = Color(0x1FFFFFFF);
  static const Color borderFocus = Color(0x80EC4899);
}
