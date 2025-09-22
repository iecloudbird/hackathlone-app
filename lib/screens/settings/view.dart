import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/settings_provider.dart';
import 'package:hackathlone_app/services/auth_service.dart';
import 'package:hackathlone_app/core/constants/app_text_styles.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/screens/settings/components/settings_section.dart';
import 'package:hackathlone_app/screens/settings/components/settings_preference_tile.dart';
import 'package:hackathlone_app/screens/settings/components/settings_action_tile.dart';
import 'package:hackathlone_app/utils/toast.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final user = _authService.getCurrentUser();
    if (user != null) {
      context.read<SettingsProvider>().loadPreferences(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();
    final isGuest = user == null;

    return Scaffold(
      backgroundColor: AppColors.maastrichtBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.appBarTitle,
        ),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 1),
          child: Container(
            height: 0.5,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ),
      body: isGuest ? _buildGuestView() : _buildAuthenticatedView(),
    );
  }

  Widget _buildGuestView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Sign In Required',
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to access your notification preferences and account settings.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightYellow,
                foregroundColor: AppColors.maastrichtBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sign In',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.maastrichtBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildGeneralSection(),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedView() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.brightYellow,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationSection(settingsProvider),
              const SizedBox(height: 24),
              _buildAccountSection(),
              const SizedBox(height: 24),
              _buildGeneralSection(),
              const SizedBox(height: 24),
              _buildDangerZoneSection(),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationSection(SettingsProvider settingsProvider) {
    final preferences = settingsProvider.preferences;
    final user = _authService.getCurrentUser();

    if (preferences == null || user == null) {
      return const SizedBox.shrink();
    }

    return SettingsSection(
      title: 'Notifications',
      subtitle: 'Manage how you receive notifications from HackAthlone',
      children: [
        SettingsPreferenceTile(
          leading: const Icon(Icons.notifications_active_outlined),
          title: 'Push Notifications',
          subtitle: 'Receive instant notifications on your device',
          value: preferences.pushNotifications,
          onChanged: (value) => settingsProvider.togglePreference(user.id, 'push'),
        ),
        SettingsPreferenceTile(
          leading: const Icon(Icons.email_outlined),
          title: 'Email Notifications',
          subtitle: 'Receive notifications via email',
          value: preferences.emailNotifications,
          onChanged: (value) => settingsProvider.togglePreference(user.id, 'email'),
        ),
        SettingsPreferenceTile(
          leading: const Icon(Icons.event_outlined),
          title: 'Event Notifications',
          subtitle: 'Get notified about upcoming events and deadlines',
          value: preferences.eventNotifications,
          onChanged: (value) => settingsProvider.togglePreference(user.id, 'event'),
        ),
        SettingsPreferenceTile(
          leading: const Icon(Icons.admin_panel_settings_outlined),
          title: 'Admin Notifications',
          subtitle: 'Important announcements from organizers',
          value: preferences.adminNotifications,
          onChanged: (value) => settingsProvider.togglePreference(user.id, 'admin'),
        ),
        SettingsPreferenceTile(
          leading: const Icon(Icons.campaign_outlined),
          title: 'Marketing Communications',
          subtitle: 'Updates about future events and opportunities',
          value: preferences.marketingNotifications,
          onChanged: (value) => settingsProvider.togglePreference(user.id, 'marketing'),
        ),
        SettingsPreferenceTile(
          leading: const Icon(Icons.warning_amber_outlined),
          title: 'Emergency Alerts',
          subtitle: 'Critical safety and security notifications',
          value: preferences.emergencyAlerts,
          onChanged: (value) => settingsProvider.togglePreference(user.id, 'emergency'),
          enabled: true, // Always enabled for safety
        ),
        SettingsPreferenceTile(
          leading: const Icon(Icons.system_update_outlined),
          title: 'System Notifications',
          subtitle: 'App updates and system maintenance alerts',
          value: preferences.systemNotifications,
          onChanged: (value) => settingsProvider.togglePreference(user.id, 'system'),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return SettingsSection(
      title: 'Account',
      children: [
        SettingsActionTile(
          leading: const Icon(Icons.person_outline),
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () => context.go('/profile'),
        ),
        SettingsActionTile(
          leading: const Icon(Icons.qr_code_2_outlined),
          title: 'My QR Code',
          subtitle: 'View and share your QR code',
          onTap: () => context.go('/qr_display'),
        ),
        SettingsActionTile(
          leading: const Icon(Icons.lock_outline),
          title: 'Privacy & Security',
          subtitle: 'Manage your privacy settings',
          onTap: () => _showComingSoonDialog('Privacy & Security settings'),
        ),
      ],
    );
  }

  Widget _buildGeneralSection() {
    return SettingsSection(
      title: 'General',
      children: [
        SettingsActionTile(
          leading: const Icon(Icons.help_outline),
          title: 'Help & Support',
          subtitle: 'Get help or contact support',
          onTap: () => _launchUrl('https://www.hackathlone.com/support'),
        ),
        SettingsActionTile(
          leading: const Icon(Icons.info_outline),
          title: 'About HackAthlone',
          subtitle: 'Learn more about our mission',
          onTap: () => _launchUrl('https://www.hackathlone.com/about-us'),
        ),
        SettingsActionTile(
          leading: const Icon(Icons.description_outlined),
          title: 'Terms of Service',
          onTap: () => _launchUrl('https://www.hackathlone.com/terms'),
        ),
        SettingsActionTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: 'Privacy Policy',
          onTap: () => _launchUrl('https://www.hackathlone.com/privacy'),
        ),
        SettingsActionTile(
          leading: const Icon(Icons.star_outline),
          title: 'Rate App',
          subtitle: 'Share your feedback with us',
          onTap: () => _showComingSoonDialog('App rating'),
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    final user = _authService.getCurrentUser();
    if (user == null) return const SizedBox.shrink();

    return SettingsSection(
      title: 'Danger Zone',
      subtitle: 'These actions are irreversible. Please be careful.',
      children: [
        SettingsActionTile(
          leading: const Icon(Icons.cleaning_services_outlined),
          title: 'Clear App Data',
          subtitle: 'Clear cached data and preferences (keeps account)',
          onTap: () => _showClearDataDialog(user.id),
        ),
        SettingsActionTile(
          leading: const Icon(Icons.logout),
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          onTap: _signOut,
        ),
        SettingsActionTile(
          leading: const Icon(Icons.delete_forever_outlined),
          title: 'Delete Account',
          subtitle: 'Permanently delete your account and all data',
          isDestructive: true,
          onTap: () => _showDeleteAccountDialog(user.id),
        ),
      ],
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.pineTree,
        title: Text(
          'Coming Soon',
          style: AppTextStyles.headingSmall,
        ),
        content: Text(
          '$feature will be available in a future update.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.brightYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.pineTree,
        title: Text(
          'Clear App Data',
          style: AppTextStyles.headingSmall,
        ),
        content: Text(
          'This will clear all cached data and reset your app preferences. Your account will remain active. Are you sure?',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonMedium.copyWith(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SettingsProvider>().clearAppData(userId);
            },
            child: Text(
              'Clear Data',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.martianRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.pineTree,
        title: Text(
          'Delete Account',
          style: AppTextStyles.headingSmall.copyWith(
            color: AppColors.martianRed,
          ),
        ),
        content: Text(
          'This will permanently delete your account and all associated data. This action cannot be undone. Are you sure?',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonMedium.copyWith(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<SettingsProvider>().deleteAccount(userId);
                await _authService.signOut();
                if (mounted && context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                // Error handling is done in the provider
              }
            },
            child: Text(
              'Delete Forever',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.martianRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final error = await _authService.signOut();
    if (error != null) {
      ToastNotification.showError('Failed to sign out');
    } else {
      ToastNotification.showSuccess('Signed out successfully');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ToastNotification.showError('Could not open link');
      }
    } catch (e) {
      ToastNotification.showError('Failed to open link');
    }
  }
}
