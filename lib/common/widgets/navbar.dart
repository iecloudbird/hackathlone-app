import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(IconsaxPlusBold.home_2),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(IconsaxPlusLinear.profile_2user),
          label: 'Team',
        ),
        BottomNavigationBarItem(
          icon: Icon(IconsaxPlusLinear.calendar),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(IconsaxPlusLinear.sms),
          label: 'Inbox',
        ),
      ],
    );
  }
}
