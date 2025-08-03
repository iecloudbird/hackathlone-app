import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Navigation bar configuration for easy management
class NavBarConfig {
  /// Navigation bar items configuration
  static const List<NavBarItem> items = [
    NavBarItem(
      id: 'home',
      icon: IconsaxPlusBold.home_2,
      label: 'Home',
      route: '/home',
    ),
    NavBarItem(
      id: 'team',
      icon: IconsaxPlusLinear.profile_2user,
      label: 'Team',
      route: '/team',
    ),
    NavBarItem(
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
    ),
  ];

  /// Get BottomNavigationBarItem list
  static List<BottomNavigationBarItem> get bottomNavItems {
    return items.map((item) => item.toBottomNavigationBarItem()).toList();
  }

  /// Get route by index
  static String getRouteByIndex(int index) {
    if (index < 0 || index >= items.length) return items.first.route;
    return items[index].route;
  }

  /// Get index by route
  static int getIndexByRoute(String route) {
    final index = items.indexWhere((item) => item.route == route);
    return index != -1 ? index : 0;
  }
}

/// Model for navigation bar item
class NavBarItem {
  final String id;
  final IconData icon;
  final String label;
  final String route;
  final bool isEnabled;

  const NavBarItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.route,
    this.isEnabled = true,
  });

  /// Convert to BottomNavigationBarItem
  BottomNavigationBarItem toBottomNavigationBarItem() {
    return BottomNavigationBarItem(icon: Icon(icon), label: label);
  }
}
