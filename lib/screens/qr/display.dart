import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/config/constants/constants.dart';
import 'package:hackathlone_app/common/widgets/secondary_appbar.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class QrDisplayPage extends StatelessWidget {
  const QrDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final UserProfile? userProfile = authProvider.userProfile;

        // Log the userProfile and qrCode value for debugging
        logger.d('UserProfile: ${authProvider.user?.id}');
        logger.d('QR Code Value: ${authProvider.userProfile?.qrCode}');

        // If profile is null, show loading and force refresh
        if (userProfile == null) {
          return Scaffold(
            appBar: AppBarWithBack(title: AppStrings.qrDisplayTitle),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000613),
                    Color(0xFF030B21),
                    Color(0xFF040D22),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: AppDimensions.paddingAll24,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.electricBlue,
                      ),
                      AppDimensions.verticalSpaceXL,
                      Text(
                        'Loading your profile...',
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      AppDimensions.verticalSpaceL,
                      ElevatedButton(
                        onPressed: () async {
                          await authProvider.forceRefreshProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Refresh Profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // If QR code is null, show error and offer to refresh
        if (userProfile.qrCode == null || userProfile.qrCode!.isEmpty) {
          return Scaffold(
            appBar: AppBarWithBack(title: AppStrings.qrDisplayTitle),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000613),
                    Color(0xFF030B21),
                    Color(0xFF040D22),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: AppDimensions.paddingAll24,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: Colors.orange,
                      ),
                      AppDimensions.verticalSpaceXL,
                      Text(
                        'Your QR code is being generated...',
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      AppDimensions.verticalSpaceM,
                      Text(
                        'This usually happens automatically. Please refresh to get your QR code.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppDimensions.verticalSpaceL,
                      ElevatedButton(
                        onPressed: () async {
                          await authProvider.forceRefreshProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Refresh to Get QR Code'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Show QR code successfully
        return Scaffold(
          appBar: AppBarWithBack(title: AppStrings.qrDisplayTitle),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF000613),
                  Color(0xFF030B21),
                  Color(0xFF040D22),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your QR Code',
                      style: TextStyle(
                        fontFamily: 'Overpass',
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Show this to admins for check-in and meals',
                      style: TextStyle(
                        fontFamily: 'Overpass',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: userProfile.qrCode!,
                        version: QrVersions.auto,
                        size: 280.0,
                        gapless: false,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // User info display
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.maastrichtBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.electricBlue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            userProfile.fullName,
                            style: const TextStyle(
                              fontFamily: 'Overpass',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProfile.email,
                            style: const TextStyle(
                              fontFamily: 'Overpass',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: userProfile.role.toLowerCase() == 'admin'
                                  ? Colors.orange.withOpacity(0.2)
                                  : AppColors.electricBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              userProfile.role.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Overpass',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: userProfile.role.toLowerCase() == 'admin'
                                    ? Colors.orange
                                    : AppColors.electricBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
