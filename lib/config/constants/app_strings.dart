// Application-wide string constants for maintainability and internationalization readiness
class AppStrings {
  // App Info
  static const String appTitle = 'Hackathlone App';
  static const String appLogo = 'assets/images/motif.png';

  // Authentication Strings
  static const String loginTitle = 'Welcome Back';
  static const String signupTitle = 'Create Account';
  static const String confirmEmailTitle = 'Confirm Your Email';
  static const String resetPasswordTitle = 'Reset Your Password';

  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String newPasswordLabel = 'New Password';
  static const String confirmPasswordLabel = 'Confirm Password';

  static const String loginButton = 'Sign In';
  static const String signupButton = 'Sign Up';
  static const String confirmEmailButton = 'Confirm Email';
  static const String updatePasswordButton = 'Update Password';
  static const String forgotPasswordButton = 'Forgot Password?';
  static const String rememberMeLabel = 'Remember me';

  static const String signupPrompt = "Don't have an account? ";
  static const String signupLink = 'Sign up';
  static const String loginPrompt = 'Already have an account? ';
  static const String loginLink = 'Sign in';

  static const String confirmEmailDescription =
      'Enter your email to confirm your account.';
  static const String resetPasswordDescription =
      'Enter your email and new password to reset your account.';

  // Success Messages
  static const String emailConfirmedSuccess = 'Email confirmed successfully';
  static const String passwordUpdatedSuccess = 'Password updated successfully';

  // QR Code Strings
  static const String qrDisplayTitle = 'Your QR Code';
  static const String qrScanTitle = 'QR Scanner';
  static const String accessDeniedTitle = 'Access Denied';
  static const String accessDeniedMessage =
      'You need to be an admin to access the QR scanner.';
  static const String selectEventTypePrompt =
      'Select event type to scan QR codes for:';
  static const String selectEventTypeHint = 'Choose event type';
  static const String scanInstructions =
      'Position QR code within the frame to scan';

  // Event Types
  static const String checkinEvent = 'Check-in';
  static const String breakfastEvent = 'Breakfast';
  static const String lunchEvent = 'Lunch';
  static const String dinnerEvent = 'Dinner';

  // Navigation/Menu
  static const String homeTitle = 'Home';
  static const String teamTitle = 'Team';
  static const String eventsTitle = 'Events';
  static const String inboxTitle = 'Inbox';
  static const String profileTitle = 'Profile';
  static const String settingsTitle = 'Settings';
  static const String mapTitle = 'Map';

  // Placeholder Content
  static const String ntkPlaceholder = 'NTK Component Placeholder';
  static const String eventsPlaceholder = 'Events Section Placeholder';

  // Common Actions
  static const String backButton = 'Back';
  static const String okButton = 'OK';
  static const String cancelButton = 'Cancel';
  static const String signOutButton = 'Sign Out';

  // Feature Coming Soon
  static const String mapFeatureComingSoon = 'Map feature coming soon!';

  // Error Messages
  static const String genericError = 'An unexpected error occurred';
  static const String networkError = 'Network connection error';
  static const String invalidCredentials = 'Invalid email or password';
  static const String emailNotConfirmed =
      'Email not confirmed. Check your email for confirmation mail.';

  // User Profile
  static const String anonymousUser = 'Anonymous User';
  static const String noSession = 'No Session';
  static const String userIdPrefix = 'ID: ';
}
