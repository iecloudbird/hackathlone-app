import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/config/navbar_config.dart';

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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: const Color(0xFF000613),
      selectedItemColor: AppColors.vividOrange,
      unselectedItemColor: Colors.white70,
      items: NavBarConfig.bottomNavItems,
    );
  }
}
