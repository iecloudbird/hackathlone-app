import 'package:flutter/material.dart';

// Application-wide dimension constants for consistent spacing and sizing
class AppDimensions {
  // Padding Constants
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 20.0;
  static const double paddingXL = 24.0;
  static const double paddingXXL = 32.0;

  // Margin Constants
  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 16.0;
  static const double marginL = 20.0;
  static const double marginXL = 24.0;
  static const double marginXXL = 32.0;

  // Border Radius Constants
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button Heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;

  // Logo and Image Sizes
  static const double logoSize = 146.0;
  static const double avatarRadius = 32.0;

  // QR Code Scanner
  static const double qrScannerSize = 250.0;
  static const double qrScannerBorderWidth = 2.0;

  // Common Widget Heights
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 60.0;

  // Spacing Helpers
  static const EdgeInsets paddingAll8 = EdgeInsets.all(paddingS);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(paddingM);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(paddingL);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(paddingXL);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(paddingXXL);

  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(
    horizontal: paddingM,
  );
  static const EdgeInsets paddingHorizontal20 = EdgeInsets.symmetric(
    horizontal: paddingL,
  );
  static const EdgeInsets paddingVertical8 = EdgeInsets.symmetric(
    vertical: paddingS,
  );
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(
    vertical: paddingM,
  );

  static const EdgeInsets marginHorizontal20 = EdgeInsets.symmetric(
    horizontal: marginL,
  );
  static const EdgeInsets marginVertical16 = EdgeInsets.symmetric(
    vertical: marginM,
  );

  // SizedBox Helpers
  static const SizedBox verticalSpaceXS = SizedBox(height: paddingXS);
  static const SizedBox verticalSpaceS = SizedBox(height: paddingS);
  static const SizedBox verticalSpaceM = SizedBox(height: paddingM);
  static const SizedBox verticalSpaceL = SizedBox(height: paddingL);
  static const SizedBox verticalSpaceXL = SizedBox(height: paddingXL);
  static const SizedBox verticalSpaceXXL = SizedBox(height: paddingXXL);

  static const SizedBox horizontalSpaceXS = SizedBox(width: paddingXS);
  static const SizedBox horizontalSpaceS = SizedBox(width: paddingS);
  static const SizedBox horizontalSpaceM = SizedBox(width: paddingM);
  static const SizedBox horizontalSpaceL = SizedBox(width: paddingL);
  static const SizedBox horizontalSpaceXL = SizedBox(width: paddingXL);
  static const SizedBox horizontalSpaceXXL = SizedBox(width: paddingXXL);

  // Border Radius Helpers
  static BorderRadius radiusSmall = BorderRadius.circular(radiusS);
  static BorderRadius radiusMedium = BorderRadius.circular(radiusM);
  static BorderRadius radiusLarge = BorderRadius.circular(radiusL);
  static BorderRadius radiusXLarge = BorderRadius.circular(radiusXL);
}
