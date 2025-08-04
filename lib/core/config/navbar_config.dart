import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Navigation bar configuration for easy management
class NavBarConfig {
  /// Navigation bar items configuration
  static List<NavBarItem> getItems({
    bool isAdmin = false,
    int unreadNotifications = 0,
  }) {
    final baseItems = [
      const NavBarItem(
        id: 'home',
        icon: IconsaxPlusBold.home_2,
        label: 'Home',
        route: '/home',
      ),
      const NavBarItem(
        id: 'team',
        icon: IconsaxPlusLinear.profile_2user,
        label: 'Team',
        route: '/team',
      ),
      const NavBarItem(
        id: 'events',
        icon: IconsaxPlusLinear.calendar,
        label: 'Events',
        route: '/events',
      ),
      NavBarItem(
        id: 'inbox',
        icon: IconsaxPlusLinear.sms,
        label: 'Inbox',
        route: '/inbox',
        showBadge: unreadNotifications > 0,
        badgeCount: unreadNotifications,
      ),
    ];

    // Add QR Scanner for admins only
    if (isAdmin) {
      baseItems.insert(
        2,
        const NavBarItem(
          id: 'qr_scanner',
          icon: IconsaxPlusLinear.scan_barcode,
          label: 'QR Scanner',
          route: '/qr_scanner',
        ),
      );
    }

    return baseItems;
  }

  /// Get BottomNavigationBarItem list
  static List<BottomNavigationBarItem> getBottomNavItems({
    bool isAdmin = false,
    int unreadNotifications = 0,
  }) {
    return getItems(
      isAdmin: isAdmin,
      unreadNotifications: unreadNotifications,
    ).map((item) => item.toBottomNavigationBarItem()).toList();
  }

  /// Get route by index
  static String getRouteByIndex(
    int index, {
    bool isAdmin = false,
    int unreadNotifications = 0,
  }) {
    final items = getItems(
      isAdmin: isAdmin,
      unreadNotifications: unreadNotifications,
    );
    if (index < 0 || index >= items.length) return items.first.route;
    return items[index].route;
  }

  /// Get index by route
  static int getIndexByRoute(
    String route, {
    bool isAdmin = false,
    int unreadNotifications = 0,
  }) {
    final items = getItems(
      isAdmin: isAdmin,
      unreadNotifications: unreadNotifications,
    );
    final index = items.indexWhere((item) => item.route == route);
    return index != -1 ? index : 0;
  }

  /// Check if route is in navigation bar
  static bool isNavBarRoute(String route, {bool isAdmin = false}) {
    final items = getItems(isAdmin: isAdmin);
    return items.any((item) => item.route == route);
  }
}

/// Model for navigation bar item
class NavBarItem {
  final String id;
  final IconData icon;
  final String label;
  final String route;
  final bool isEnabled;
  final bool showBadge;
  final int badgeCount;

  const NavBarItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.route,
    this.isEnabled = true,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  /// Convert to BottomNavigationBarItem with optional badge
  BottomNavigationBarItem toBottomNavigationBarItem() {
    return BottomNavigationBarItem(
      icon: showBadge && badgeCount > 0
          ? Badge(
              label: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red,
              textColor: Colors.white,
              child: Icon(icon),
            )
          : Icon(icon),
      label: label,
    );
  }

  /// Create a copy with updated badge information
  NavBarItem copyWith({
    String? id,
    IconData? icon,
    String? label,
    String? route,
    bool? isEnabled,
    bool? showBadge,
    int? badgeCount,
  }) {
    return NavBarItem(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      label: label ?? this.label,
      route: route ?? this.route,
      isEnabled: isEnabled ?? this.isEnabled,
      showBadge: showBadge ?? this.showBadge,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }
}
