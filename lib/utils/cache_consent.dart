import 'package:shared_preferences/shared_preferences.dart';

/// Manages user consent for caching profile data locally
class CacheConsent {
  static const String _consentKey = 'user_consent_cache';
  static const String _currentUserKey = 'current_user_id';
  static const String _anonymousModeKey = 'anonymous_mode';

  /// Check if current user has given consent to cache their profile
  static Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  /// Get the currently cached user ID (if any)
  static Future<String?> getCurrentCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  /// Set user consent for caching and track which user gave consent
  static Future<void> setConsent(bool consent, String? userId) async {
    final prefs = await SharedPreferences.getInstance();

    if (consent && userId != null) {
      // User gives consent - store consent and user ID
      await prefs.setBool(_consentKey, true);
      await prefs.setString(_currentUserKey, userId);
      print('✅ Cache consent granted for user: $userId');
    } else {
      // User revokes consent or signs out - clear everything
      await prefs.remove(_consentKey);
      await prefs.remove(_currentUserKey);
      print('🗑️ Cache consent revoked, clearing stored data');
    }
  }

  /// Check if a different user is trying to sign in (prevents cross-contamination)
  static Future<bool> isDifferentUser(String newUserId) async {
    final currentUserId = await getCurrentCachedUserId();
    return currentUserId != null && currentUserId != newUserId;
  }

  /// Clear all cache consent data (nuclear option)
  static Future<void> clearAllConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentKey);
    await prefs.remove(_currentUserKey);
    await prefs.remove(_anonymousModeKey);
    print('🧹 All cache consent data cleared');
  }

  /// Check if user is in anonymous mode
  static Future<bool> isAnonymousMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_anonymousModeKey) ?? false;
  }

  /// Set anonymous mode state
  static Future<void> setAnonymousMode(bool isAnonymous) async {
    final prefs = await SharedPreferences.getInstance();
    if (isAnonymous) {
      await prefs.setBool(_anonymousModeKey, true);
      // Clear any existing cache consent when going anonymous
      await setConsent(false, null);
      print('👤 Anonymous mode enabled');
    } else {
      await prefs.remove(_anonymousModeKey);
      print('👤 Anonymous mode disabled');
    }
  }

  /// Get summary of current cache state (for debugging)
  static Future<Map<String, dynamic>> getCacheState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hasConsent': prefs.getBool(_consentKey) ?? false,
      'currentUserId': prefs.getString(_currentUserKey),
      'isAnonymous': prefs.getBool(_anonymousModeKey) ?? false,
    };
  }
}
