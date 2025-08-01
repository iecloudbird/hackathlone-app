import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/models/common/drawer_config.dart';
import 'package:hackathlone_app/config/constants/constants.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Drawer(
      child: Container(
        color: AppColors.deepBlue,
        child: ListView(
          padding: EdgeInsets.only(
            top: statusBarHeight + AppDimensions.paddingM,
          ),
          children: [
            // User Profile Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                final userProfile = authProvider.userProfile;
                final displayName =
                    userProfile?.fullName ??
                    (user?.email ?? AppStrings.anonymousUser);
                final displayId = user?.id ?? AppStrings.noSession;

                return DrawerConfig.buildProfileSection(
                  displayName: displayName,
                  displayId: displayId,
                  isAuthenticated: user != null,
                  showUserId: true, // Remove later, for testing purposes
                );
              },
            ),

            // Menu Items
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                final userRole = authProvider.userProfile?.role;

                final drawerItems = DrawerConfig.getDrawerItems(
                  context,
                  isAuthenticated: user != null,
                  userRole: userRole,
                  onForceRefreshProfile: () async {
                    await authProvider.forceRefreshProfile();
                  },
                );

                return Column(
                  children: drawerItems
                      .map(
                        (item) => DrawerConfig.buildDrawerItem(context, item),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
