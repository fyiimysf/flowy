// lib/utils/constants/colors.dart

import 'package:flutter/material.dart';

/// Girl-friendly color palette for Flowy
/// Soft pinks, warm tones, and feminine accents with claymorphism aesthetics
class AppColors {
  // Primary Colors - Soft Pink Family (Claymorphism Style)
  static const Color primary = Color(0xFFEC4899); // Rose Pink
  static const Color primaryLight = Color(0xFFF9A8D4); // Light Pink
  static const Color primaryDark = Color(0xFFBE185D); // Dark Rose
  static const Color primaryAccent = Color(0xFFF472B6); // Hot Pink

  // Secondary Colors - Complementary Pastels
  static const Color secondary = Color(0xFF8B5CF6); // Lavender
  static const Color secondaryLight = Color(0xFFC4B5FD); // Light Lavender
  static const Color peach = Color(0xFFFDBA74); // Soft Peach
  static const Color mint = Color(0xFF6EE7B7); // Mint Green
  static const Color cream = Color(0xFFFFFBEB); // Warm Cream
  static const Color lilac = Color(0xFFE0E7FF); // Soft Lilac

  // Background Colors
  static const Color backgroundLight = Color(0xFFFDF2F8); // Pink tint white
  static const Color backgroundDark = Color(0xFF1A0B2E); // Dark purple
  static const Color cardLight = Color(0xFFFFFFFF); // Pure white
  static const Color cardDark = Color(0xFF2D1B4E); // Dark purple card
  static const Color surfaceLight = Color(0xFFFCE7F3); // Very light pink
  static const Color surfaceCream = Color(0xFFFFF7ED); // Cream surface

  // Fertility Colors
  static const Color ovulation = Color(0xFFFFAA00); // Purple (lavender)
  static const Color fertile = Color(0xFF10B981); // Green (fresh)
  static const Color period = Color(0xFFEC4899); // Pink
  static const Color predicted = Color(0xFFA700FA); // Light lavender
  static const Color today = Color(0xFF60A5FA); // Soft blue

  // Phase Colors - Soft pastels
  static final Color menstrual = const Color(0xFFEC4899).withOpacity(0.85);
  static final Color follicular = const Color(0xFF10B981).withOpacity(0.85);
  static final Color ovulationPhase = const Color(0xFFFFAA00).withOpacity(0.85);
  static final Color luteal = const Color(0xFF6F9A3A).withOpacity(0.85);

  // Text Colors
  static const Color textPrimary = Color(0xFF831843); // Dark rose
  static const Color textSecondary = Color(0xFF9D174D); // Medium rose
  static const Color textLight = Color(0xFFFBCFE8); // Very light pink
  static const Color textMuted = Color(0xFFA8557C); // Muted rose
  static const Color textOnPrimary = Colors.white; // White on pink

  // Utility Colors
  static final Color shadow = const Color(0xFFEC4899).withOpacity(0.12);
  static final Color shadowLight = const Color(0xFFFCE7F3).withOpacity(0.5);
  static final Color shadowDark = const Color(0xFFFBCFE8).withOpacity(0.3);
  static const Color divider = Color(0xFFFCE7F3); // Light pink divider
  static const Color error = Color(0xFFEF4444); // Soft red
  static const Color success = Color(0xFF10B981); // Mint green
  static const Color warning = Color(0xFFF59E0B); // Soft orange

  // Claymorphism Specific Colors
  static const Color claySurface = Color(0xFFFDF2F8);
  static const Color clayHighlight = Color(0xFFFFFFFF);
  static const Color clayShadow = Color(0xFFFBCFE8);

  // Gradient Colors
  static const List<Color> gradientPrimary = [
    Color(0xFFEC4899),
    Color(0xFFF472B6),
  ];

  static const List<Color> gradientSoft = [
    Color(0xFFFDF2F8),
    Color(0xFFFCE7F3),
  ];

  static const List<Color> gradientSunset = [
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
  ];
}
