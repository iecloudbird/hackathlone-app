import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';

// Centralized text styles for consistent typography throughout the app
class AppTextStyles {
  // Base font family
  static const String _fontFamily = 'Overpass';

  // Heading Styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.3,
  );

  // Body Text Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.4,
  );

  static const TextStyle bodyTiny = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.4,
  );

  // Specific UI Component Styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // AppBar Specific
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Form Field Styles
  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white54,
  );

  static const TextStyle errorText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.redAccent,
  );

  // Link Styles
  static const TextStyle link = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.electricBlue,
    decoration: TextDecoration.underline,
  );

  static const TextStyle linkSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.electricBlue,
    decoration: TextDecoration.underline,
  );

  // Special Use Cases
  static const TextStyle qrInstructions = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
    height: 1.4,
  );

  static const TextStyle userProfileName = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle userProfileId = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );

  // Gradient Text (for special occasions)
  static TextStyle get gradientHeading => headingLarge.copyWith(
    foreground: Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.electricBlue, AppColors.spiroDiscoBall],
      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
  );
}
