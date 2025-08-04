import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/utils/qr_utils.dart';

class ProfileController {
  static Future<void> signOut(BuildContext context) async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      if (context.mounted) {
        context.pushReplacement(AppRoutes.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows the user's QR code in a modal dialog with error handling
  static void showUserQrCode(BuildContext context) {
    final userProfile = context.read<AuthProvider>().userProfile;

    QrUtils.showQrCodeModalSafe(
      context: context,
      qrData: userProfile?.qrCode,
      title: 'Your QR Code',
      errorMessage: 'QR Code not available',
    );
  }

  /// Updates the user profile with validation and error handling
  static Future<bool> updateProfile({
    required BuildContext context,
    required String fullName,
    String? jobRole,
    String? tshirtSize,
    String? dietaryPreferences,
    List<String>? skills,
    String? avatarUrl,
  }) async {
    try {
      final authProvider = context.read<AuthProvider>();

      await authProvider.updateUserProfile(
        fullName: fullName.trim(),
        jobRole: jobRole,
        tshirtSize: tshirtSize,
        dietaryPreferences: dietaryPreferences,
        skills: skills?.isEmpty == true ? null : skills,
        avatarUrl: avatarUrl,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  static void showFeatureComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  static void handleAvatarTap(BuildContext context) {
    // TODO: Implement image picker and upload functionality
    // Future implementation will:
    // 1. Show image picker (camera/gallery)
    // 2. Upload image to Supabase storage
    // 3. Get uploaded image URL
    // 4. Update profile with new avatar URL
    // 5. This will automatically update updatedAt field for cache invalidation
    showFeatureComingSoon(context, 'Image picker');
  }

  /// Validates if profile can be edited
  static bool canEditProfile(BuildContext context) {
    final userProfile = context.read<AuthProvider>().userProfile;
    return userProfile != null;
  }

  /// Gets the current user profile safely
  static dynamic getCurrentUserProfile(BuildContext context) {
    return context.read<AuthProvider>().userProfile;
  }
}
