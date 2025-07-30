import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/services/auth_service.dart';
import 'package:hackathlone_app/config/constants/constants.dart';
import 'package:hackathlone_app/core/theme.dart';

// Enum for drawer item types
enum DrawerItemType { navigation, action, divider }

// Model for drawer menu items
class DrawerMenuItem {
  final String id;
  final String title;
  final IconData icon;
  final DrawerItemType type;
  final String? route;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool showBadge;
  final String? badgeText;

  const DrawerMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    this.type = DrawerItemType.navigation,
    this.route,
    this.onTap,
    this.isEnabled = true,
    this.showBadge = false,
    this.badgeText,
  });

  // Create a navigation item
  static DrawerMenuItem navigation({
    required String id,
    required String title,
    required IconData icon,
    required String route,
    bool isEnabled = true,
    bool showBadge = false,
    String? badgeText,
  }) {
    return DrawerMenuItem(
      id: id,
      title: title,
      icon: icon,
      type: DrawerItemType.navigation,
      route: route,
      isEnabled: isEnabled,
      showBadge: showBadge,
      badgeText: badgeText,
    );
  }

  // Create an action item
  static DrawerMenuItem action({
    required String id,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return DrawerMenuItem(
      id: id,
      title: title,
      icon: icon,
      type: DrawerItemType.action,
      onTap: onTap,
      isEnabled: isEnabled,
    );
  }

  // Create a divider
  static const DrawerMenuItem divider = DrawerMenuItem(
    id: 'divider',
    title: '',
    icon: Icons.horizontal_rule,
    type: DrawerItemType.divider,
  );
}

// Drawer configuration class
class DrawerConfig {
  // Get drawer items based on user role and authentication status
  static List<DrawerMenuItem> getDrawerItems(
    BuildContext context, {
    bool isAuthenticated = false,
    String? userRole,
  }) {
    final List<DrawerMenuItem> items = [];

    // Profile section
    items.add(
      DrawerMenuItem.navigation(
        id: 'profile',
        title: AppStrings.profileTitle,
        icon: IconsaxPlusBold.profile,
        route: '/profile', // AppRoutes.profile when implemented
        isEnabled: false, // Disabled until route is implemented
      ),
    );

    // Settings
    items.add(
      DrawerMenuItem.navigation(
        id: 'settings',
        title: AppStrings.settingsTitle,
        icon: IconsaxPlusBold.setting_2,
        route: '/settings', // AppRoutes.settings when implemented
        isEnabled: false, // Disabled until route is implemented
      ),
    );

    // QR Scanner (Admin only)
    if (userRole == 'admin') {
      items.add(
        DrawerMenuItem.navigation(
          id: 'qr_scan',
          title: AppStrings.qrScanTitle,
          icon: IconsaxPlusLinear.scan_barcode,
          route: AppRoutes.qrScan,
        ),
      );
    }

    // Map feature
    items.add(
      DrawerMenuItem.action(
        id: 'map',
        title: AppStrings.mapTitle,
        icon: IconsaxPlusLinear.map,
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.mapFeatureComingSoon)),
          );
        },
      ),
    );

    // Divider before sign out
    items.add(DrawerMenuItem.divider);

    // Sign out
    if (isAuthenticated) {
      items.add(
        DrawerMenuItem.action(
          id: 'sign_out',
          title: AppStrings.signOutButton,
          icon: IconsaxPlusLinear.logout,
          onTap: () async {
            await AuthService().signOut();
            if (context.mounted) {
              context.go(AppRoutes.login);
            }
          },
        ),
      );
    }

    return items;
  }

  // Build a ListTile widget for a drawer item
  static Widget buildDrawerItem(BuildContext context, DrawerMenuItem item) {
    switch (item.type) {
      case DrawerItemType.divider:
        return const Divider(color: Colors.white24, thickness: 1);

      case DrawerItemType.navigation:
      case DrawerItemType.action:
        return ListTile(
          enabled: item.isEnabled,
          leading: Icon(
            item.icon,
            color: item.isEnabled ? Colors.white : Colors.white38,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: item.isEnabled ? Colors.white : Colors.white38,
                  ),
                ),
              ),
              if (item.showBadge) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.badgeText ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: item.isEnabled
              ? () {
                  Navigator.pop(context);

                  if (item.type == DrawerItemType.navigation &&
                      item.route != null) {
                    context.go(item.route!);
                  } else if (item.type == DrawerItemType.action &&
                      item.onTap != null) {
                    item.onTap!();
                  }
                }
              : null,
        );
    }
  }

  // Profile section configuration
  static Widget buildProfileSection({
    required String displayName,
    required String displayId,
    required bool isAuthenticated,
    required bool showUserId,
  }) {
    return Padding(
      padding: AppDimensions.paddingAll16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.electricBlue,
                  radius: AppDimensions.avatarRadius,
                  child: Icon(
                    isAuthenticated
                        ? IconsaxPlusBold.profile
                        : IconsaxPlusLinear.profile,
                    color: Colors.white,
                    size: AppDimensions.iconL,
                  ),
                ),
                AppDimensions.verticalSpaceS,
                Text(displayName, style: AppTextStyles.userProfileName),
                if (showUserId) ...[
                  Text(
                    '${AppStrings.userIdPrefix}$displayId',
                    style: AppTextStyles.userProfileId,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
