import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:hackathlone_app/common/widgets/secondary_appbar.dart';
import 'package:hackathlone_app/config/constants/constants.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class QrDisplayPage extends StatelessWidget {
  const QrDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final UserProfile? userProfile = authProvider.userProfile;

    // Enhanced logging for debugging
    logger.d('=== QR Display Page Debug ===');
    logger.d('User: ${authProvider.user?.id ?? 'No user'}');
    logger.d('UserProfile: ${userProfile?.fullName ?? 'No profile'}');
    logger.d('UserProfile ID: ${userProfile?.id ?? 'No ID'}');
    logger.d('QR Code Value: ${userProfile?.qrCode ?? 'No QR code'}');
    logger.d('Is authenticated: ${authProvider.isAuthenticated}');
    logger.d('Is loading: ${authProvider.isLoading}');
    logger.d('============================');

    if (userProfile == null || userProfile.qrCode == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF000613),
        appBar: SecondaryAppBar(title: AppStrings.qrDisplayTitle),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code,
                size: AppDimensions.iconXL,
                color: Colors.white54,
              ),
              AppDimensions.verticalSpaceM,
              Text(
                userProfile == null
                    ? 'Loading profile...'
                    : 'No QR code available.\nPlease complete your profile.',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (authProvider.isLoading)
                Padding(
                  padding: AppDimensions.paddingVertical16,
                  child: const CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: SecondaryAppBar(title: AppStrings.qrDisplayTitle),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000613), Color(0xFF030B21), Color(0xFF040D22)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: AppDimensions.paddingAll16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDimensions.radiusLarge,
                  ),
                  child: QrImageView(
                    data: userProfile.qrCode!,
                    version: QrVersions.auto,
                    size: 300.0,
                    gapless: false,
                  ),
                ),
                AppDimensions.verticalSpaceXXL,
                Text(
                  'Show this QR code to event staff',
                  style: AppTextStyles.qrInstructions,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
