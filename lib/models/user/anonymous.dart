import 'package:hackathlone_app/models/user/profile.dart';

/// Anonymous/Guest user functionality for public access
class AnonymousUser {
  // Constants for anonymous user
  static const String id = 'anonymous_user';
  static const String name = 'Guest User';
  static const String email = 'guest@local.app';
  static const String role = 'guest';
  static const String avatarUrl = '';

  /// Create anonymous user profile (no caching, no FCM)
  static UserProfile createProfile() {
    return UserProfile(
      id: id,
      email: email,
      fullName: name,
      role: role,
      avatarUrl: avatarUrl,
      bio: 'Browse the app as a guest user',
      jobRole: 'Guest',
      skills: [],
      dietaryPreferences: '',
      tshirtSize: '',
      phone: '',
      qrCode: null, // Anonymous users don't get QR codes
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Check if a profile is anonymous
  static bool isAnonymousProfile(UserProfile? profile) {
    return profile?.id == id;
  }

  /// Features available to anonymous users
  static const List<String> availableFeatures = [
    'browse_events', // Can view public events
    'view_schedule', // Can see event schedule
    'read_information', // Can read public information
    'contact_info', // Can view contact information
  ];

  /// Features restricted for anonymous users
  static const List<String> restrictedFeatures = [
    'qr_code', // No QR code access
    'profile_edit', // Cannot edit profile
    'event_register', // Cannot register for events
    'notifications', // No push notifications
    'meal_tracking', // No meal allowance tracking
    'check_in', // Cannot check in to events
    'admin_features', // No admin access
  ];

  /// Check if feature is available to anonymous users
  static bool canAccessFeature(String feature) {
    return availableFeatures.contains(feature);
  }

  /// Get upgrade message for restricted features
  static String getUpgradeMessage(String feature) {
    switch (feature) {
      case 'qr_code':
        return 'Sign in to get your personal QR code for event check-ins';
      case 'event_register':
        return 'Sign in to register for events and access exclusive content';
      case 'notifications':
        return 'Sign in to receive event updates and notifications';
      case 'profile_edit':
        return 'Sign in to create and customize your profile';
      case 'meal_tracking':
        return 'Sign in to track your meal allowances and dietary preferences';
      default:
        return 'Sign in to access more features and personalize your experience';
    }
  }

  /// CTAs for different contexts
  static const Map<String, String> ctaTexts = {
    'profile': 'Sign in to unlock your profile',
    'qr_code': 'Sign in to get your QR code',
    'events': 'Sign in to register for events',
    'notifications': 'Sign in for personalized updates',
    'general': 'Sign in to access more features',
  };

  /// Get appropriate CTA text for context
  static String getCTAText(String context) {
    return ctaTexts[context] ?? ctaTexts['general']!;
  }
}
