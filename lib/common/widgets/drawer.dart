import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/config/drawer_config.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Drawer(
      child: Container(
        color: AppColors.deepBlue,
        child: Column(
          children: [
            // User Profile Section using configuration
            Padding(
              padding: EdgeInsets.only(top: statusBarHeight + 16.0),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  final userProfile = authProvider.userProfile;
                  final displayName =
                      userProfile?.fullName ??
                      (user?.email ?? 'Anonymous User');
                  final displayId = user?.id ?? 'No Session';
                  final isAuthenticated = authProvider.isAuthenticated;

                  return DrawerConfig.buildProfileSection(
                    context: context,
                    displayName: displayName,
                    displayId: displayId,
                    isAuthenticated: isAuthenticated,
                    showUserId: true, // Set to false in production
                  );
                },
              ),
            ),

            // Expandable content area
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final isAuthenticated = authProvider.isAuthenticated;
                  final userRole = authProvider.userProfile?.role;

                  final drawerItems = DrawerConfig.getDrawerItems(
                    context,
                    isAuthenticated: isAuthenticated,
                    userRole: userRole,
                    onForceRefreshProfile: () async {
                      await authProvider.forceRefreshProfile();
                    },
                  );

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: drawerItems.map((item) {
                      return DrawerConfig.buildDrawerItem(context, item);
                    }).toList(),
                  );
                },
              ),
            ),

            // Sign out button at bottom
            SafeArea(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final isAuthenticated = authProvider.isAuthenticated;
                  final signOutItem = DrawerConfig.getSignOutItem(
                    context,
                    isAuthenticated: isAuthenticated,
                  );

                  if (signOutItem == null) return const SizedBox.shrink();

                  return Column(
                    children: [
                      const Divider(color: Colors.white24, thickness: 1),
                      DrawerConfig.buildDrawerItem(context, signOutItem),
                      const SizedBox(height: 4),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
