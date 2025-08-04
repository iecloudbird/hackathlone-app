import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/config/navbar_config.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';

class HomeNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap; // Callback to handle navigation

  const HomeNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NotificationProvider>(
      builder: (context, authProvider, notificationProvider, child) {
        final isAdmin = authProvider.userProfile?.role == 'admin';
        final unreadCount = notificationProvider.unreadCount;

        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: const Color(0xFF000613),
          selectedItemColor: AppColors.vividOrange,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          items: NavBarConfig.getBottomNavItems(
            isAdmin: isAdmin,
            unreadNotifications: unreadCount,
          ),
        );
      },
    );
  }
}
