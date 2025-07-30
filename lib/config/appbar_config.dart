import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Configuration for app bar actions and behavior
class AppBarConfig {
  /// Home app bar action items configuration
  static List<AppBarActionItem> get homeActions => [
    AppBarActionItem(
      icon: IconsaxPlusLinear.map,
      tooltip: 'Map',
      onPressed: (context) {
        // TODO: Implement map functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Map feature coming soon!')),
        );
      },
    ),
    AppBarActionItem(
      icon: IconsaxPlusLinear.scan_barcode,
      tooltip: 'QR Code',
      onPressed: (context) {
        context.go(AppRoutes.qrDisplay);
      },
    ),
  ];

  /// Leading menu button configuration
  static AppBarLeadingItem get menuButton => AppBarLeadingItem(
    icon: IconsaxPlusBold.element_2,
    tooltip: 'Menu',
    onPressed: (context) {
      Scaffold.of(context).openDrawer();
    },
  );
}

/// Represents an action item in the app bar
class AppBarActionItem {
  final IconData icon;
  final String tooltip;
  final void Function(BuildContext context) onPressed;
  final Color? iconColor;
  final double? iconSize;

  const AppBarActionItem({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor = Colors.white,
    this.iconSize,
  });

  /// Convert to IconButton widget
  Widget toIconButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-16.0, 0.0),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: iconSize),
        tooltip: tooltip,
        onPressed: () => onPressed(context),
      ),
    );
  }
}

/// Represents the leading item in the app bar
class AppBarLeadingItem {
  final IconData icon;
  final String tooltip;
  final void Function(BuildContext context) onPressed;
  final Color? iconColor;
  final double? iconSize;

  const AppBarLeadingItem({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor = Colors.white,
    this.iconSize,
  });

  /// Convert to IconButton widget
  Widget toIconButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(16.0, 0.0),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: iconSize),
        tooltip: tooltip,
        onPressed: () => onPressed(context),
      ),
    );
  }
}
