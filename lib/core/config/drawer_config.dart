import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/core/constants/constants.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/main.dart';
import 'package:hackathlone_app/common/widgets/image_picker.dart';
import 'package:hackathlone_app/screens/home/widgets/admin_notification_modal.dart';

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
  // Helper method to open Google Maps
  static Future<void> _openVenueMap() async {
    final Uri url = Uri.parse(AppStrings.venueMapUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  // Helper method to copy text to clipboard
  static Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // Get drawer items based on user role and authentication status
  static List<DrawerMenuItem> getDrawerItems(
    BuildContext context, {
    bool isAuthenticated = false,
    String? userRole,
    Future<void> Function()? onForceRefreshProfile,
  }) {
    final List<DrawerMenuItem> items = [];

    // Divider after profile section
    items.add(DrawerMenuItem.divider);

    // Profile section
    items.add(
      DrawerMenuItem.navigation(
        id: 'profile',
        title: AppStrings.profileTitle,
        icon: IconsaxPlusBold.profile,
        route: AppRoutes.profile,
        isEnabled: true,
      ),
    );

    // Map feature
    items.add(
      DrawerMenuItem.action(
        id: 'map',
        title: AppStrings.mapTitle,
        icon: IconsaxPlusLinear.map,
        onTap: () async {
          try {
            await _openVenueMap();
          } catch (e) {
            // Use a delay to ensure drawer is closed before showing snackbar
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open map: $e')),
                );
              }
            });
          }
        },
      ),
    );

    /// Admin-only features
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

      // Send Notifications (Admin only)
      items.add(
        DrawerMenuItem.action(
          id: 'send_notification',
          title: 'Send Notification',
          icon: IconsaxPlusLinear.notification,
          onTap: () {
            AdminNotificationModal.show(context);
          },
        ),
      );

      // Force refresh profile (Admin only)
      if (onForceRefreshProfile != null) {
        items.add(
          DrawerMenuItem.action(
            id: 'force_refresh_profile',
            title: AppStrings.refreshProfileTitle,
            icon: IconsaxPlusLinear.refresh,
            onTap: () async {
              await onForceRefreshProfile();

              // Show success message after a brief delay to ensure navigation completes
              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile refreshed from database'),
                    ),
                  );
                }
              });
            },
          ),
        );
      }
    }

    // Settings (at the end)
    items.add(
      DrawerMenuItem.navigation(
        id: 'settings',
        title: AppStrings.settingsTitle,
        icon: IconsaxPlusBold.setting_2,
        route: '/settings', // AppRoutes.settings when implemented
        isEnabled: false, // Disabled until route is implemented
      ),
    );

    return items;
  }

  // Get sign out item separately to position at bottom
  static DrawerMenuItem? getSignOutItem(
    BuildContext context, {
    required bool isAuthenticated,
  }) {
    if (!isAuthenticated) return null;

    return DrawerMenuItem.action(
      id: 'sign_out',
      title: AppStrings.signOutButton,
      icon: IconsaxPlusLinear.logout,
      onTap: () async {
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();

        final router = GoRouter.of(navigatorKey.currentContext!);
        router.pushReplacement(AppRoutes.login);
      },
    );
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
                  Navigator.pop(context); // Close drawer first

                  if (item.type == DrawerItemType.navigation &&
                      item.route != null) {
                    // Use push for drawer navigation to maintain back stack
                    context.push(item.route!);
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
    required BuildContext context,
    required String displayName,
    required String displayId,
    required bool isAuthenticated,
    required bool showUserId,
    String? avatarUrl,
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
                ProfileImagePicker(
                  imageUrl: avatarUrl,
                  size: AppDimensions.avatarRadius * 2,
                  showEditIcon: false,
                  isEditable: false,
                ),
                AppDimensions.verticalSpaceS,
                Text(displayName, style: AppTextStyles.userProfileName),
                if (showUserId) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${AppStrings.userIdPrefix}$displayId',
                          style: AppTextStyles.userProfileId,
                        ),
                      ),
                      AppDimensions.horizontalSpaceXS,
                      GestureDetector(
                        onTap: () => _copyToClipboard(displayId),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.brightYellow.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.brightYellow.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            IconsaxPlusLinear.copy,
                            size: 14,
                            color: AppColors.brightYellow,
                          ),
                        ),
                      ),
                    ],
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
