import 'package:flutter/material.dart';

/// Red & Black premium design system — sleek, minimal, high-contrast
class AppColors {
  // --- Primary Brand ---
  static const Color primary = Color(0xFFE53E3E); // Vivid Red
  static const Color primaryDark = Color(0xFFC53030); // Deep Red
  static const Color primaryLight = Color(0xFFFFF5F5); // Very light red tint

  // --- Neutral & Surface ---
  static const Color black = Color(0xFF0D0D0D); // Near black
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color background = Color(0xFFF7F7F7); // Off-white bg
  static const Color card = Color(0xFFFFFFFF); // Card white
  static const Color darkCard = Color(0xFF1A1A1A); // Dark card for dark areas

  // --- Text ---
  static const Color textPrimary = Color(0xFF0D0D0D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnRed = Color(0xFFFFFFFF);

  // --- Borders & Dividers ---
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF2D2D2D);

  // --- Status ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color rating = Color(0xFFF59E0B);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE53E3E), Color(0xFF991B1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF1F1F1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft card shadow (barely visible for clean look)
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> redShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
