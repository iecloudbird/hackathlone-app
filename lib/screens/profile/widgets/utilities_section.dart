import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/constants.dart';

/// Widget for displaying utility actions in the profile screen
class UtilitiesSection extends StatelessWidget {
  final VoidCallback onQrCodeTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onSignOutTap;

  const UtilitiesSection({
    super.key,
    required this.onQrCodeTap,
    required this.onSettingsTap,
    required this.onSignOutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Utilities',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
        AppDimensions.verticalSpaceM,

        // QR Code
        _buildUtilityTile(
          icon: IconsaxPlusLinear.scan_barcode,
          title: 'QR Code',
          subtitle: 'View your QR code',
          onTap: onQrCodeTap,
        ),
        AppDimensions.verticalSpaceM,

        // Settings
        _buildUtilityTile(
          icon: IconsaxPlusLinear.setting_2,
          title: 'Settings',
          subtitle: 'App preferences and notifications',
          onTap: onSettingsTap,
        ),
        AppDimensions.verticalSpaceM,

        // Sign Out
        _buildUtilityTile(
          icon: IconsaxPlusLinear.logout,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          onTap: onSignOutTap,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildUtilityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.2)
                : AppColors.brightYellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.brightYellow,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
        ),
        trailing: Icon(
          IconsaxPlusLinear.arrow_right_3,
          color: Colors.white38,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
