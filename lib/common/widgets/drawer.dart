import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/services/auth_service.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Drawer(
      child: Container(
        color: AppColors.deepBlue,
        child: ListView(
          padding: EdgeInsets.only(top: statusBarHeight + 16.0),
          children: [
            // User Profile Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                final userProfile = authProvider.userProfile;
                final displayName =
                    userProfile?['name'] ?? (user?.email ?? 'Anonymous User');
                final displayId = user?.id ?? 'No Session';

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.electricBlue,
                              radius: 32,
                              child: Icon(
                                user != null
                                    ? IconsaxPlusBold.profile
                                    : IconsaxPlusLinear.profile,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontFamily: 'Overpass',
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'ID: $displayId',
                              style: const TextStyle(
                                fontFamily: 'Overpass',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ), //Remove later, for testing purposes
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(color: Colors.white24, thickness: 1),
            ListTile(
              leading: const Icon(IconsaxPlusBold.profile, color: Colors.white),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // context.go(AppRoutes.profile);
              },
            ),
            ListTile(
              leading: const Icon(
                IconsaxPlusBold.setting_2,
                color: Colors.white,
              ),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // context.go(AppRoutes.settigns);
              },
            ),
            ListTile(
              leading: const Icon(
                IconsaxPlusLinear.scan_barcode,
                color: Colors.white,
              ),
              title: const Text(
                'Scan QR Code',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // context.go(AppRoutes.qrcode);
              },
            ),
            ListTile(
              leading: const Icon(IconsaxPlusLinear.map, color: Colors.white),
              title: const Text('Map', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to inbox
              },
            ),
            ListTile(
              leading: const Icon(
                IconsaxPlusLinear.logout,
                color: Colors.white,
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                AuthService().signOut();
                // Navigate to inbox
              },
            ),
          ],
        ),
      ),
    );
  }
}
