import 'package:flutter/material.dart';

class AppDecorations {
  // Common background gradient used throughout the app
  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF000613), Color(0xFF030B21), Color(0xFF040D22)],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  // Card decoration with gradient
  static const BoxDecoration cardGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF131212), Color(0xFF1A1A1A)],
      stops: [0.0, 1.0],
    ),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  );

  // Input field decoration
  static BoxDecoration inputFieldDecoration = BoxDecoration(
    color: const Color(0xFF131212),
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
  );
}
