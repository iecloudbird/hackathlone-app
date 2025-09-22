import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/common/widgets/secondary_appbar.dart';

class AnonymousProfile extends StatelessWidget {
  const AnonymousProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      appBar: AppBarWithBack(title: ''), // Empty title for back button only
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Anonymous Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.blueYonder.withValues(alpha: 0.3),
                        AppColors.electricBlue.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.blueYonder.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    IconsaxPlusBold.user,
                    size: 50,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 24),

                // Guest User Title
                Text(
                  'Guest User',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Browsing in preview mode',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),

                const SizedBox(height: 40),

                // Feature Preview Cards
                ..._buildFeaturePreviewCards(context),

                const SizedBox(height: 32),

                // CTAs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Primary CTA
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => context.go(AppRoutes.login),
                          icon: Icon(Icons.login, size: 20),
                          label: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueYonder,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      // Secondary CTA
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => context.go(AppRoutes.signup),
                          icon: Icon(Icons.person_add, size: 20),
                          label: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.brightYellow,
                            side: BorderSide(
                              color: AppColors.brightYellow,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build feature preview cards for anonymous users
  List<Widget> _buildFeaturePreviewCards(BuildContext context) {
    final features = [
      {
        'icon': IconsaxPlusLinear.scan_barcode,
        'title': 'Personal QR Code',
        'description': 'Get your unique QR code for quick event check-ins',
        'available': false,
      },
      {
        'icon': IconsaxPlusLinear.notification,
        'title': 'Event Notifications',
        'description':
            'Receive updates about events and important announcements',
        'available': false,
      },
      {
        'icon': IconsaxPlusLinear.user_edit,
        'title': 'Custom Profile',
        'description': 'Personalize your profile with skills and preferences',
        'available': false,
      },
      {
        'icon': IconsaxPlusLinear.calendar_tick,
        'title': 'Event Registration',
        'description': 'Register for events and track your participation',
        'available': false,
      },
    ];

    return features
        .map(
          (feature) => Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: feature['available'] as bool
                        ? AppColors.blueYonder.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: feature['available'] as bool
                        ? AppColors.blueYonder
                        : Colors.white.withValues(alpha: 0.4),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            feature['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (!(feature['available'] as bool))
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brightYellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.brightYellow.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Participant',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brightYellow,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        feature['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
