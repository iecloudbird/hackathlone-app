import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/config/constants/constants.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Configuration for app bar actions and behavior
class AppBarConfig {
  /// Helper method to open Google Maps
  static Future<void> _openVenueMap(BuildContext context) async {
    final Uri url = Uri.parse(AppStrings.venueMapUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Google Maps');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open map: $e')));
      }
    }
  }

  /// Home app bar action items configuration
  static List<AppBarActionItem> get homeActions => [
    AppBarActionItem(
      icon: IconsaxPlusLinear.map,
      tooltip: 'Map',
      onPressed: (context) async {
        await _openVenueMap(context);
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
