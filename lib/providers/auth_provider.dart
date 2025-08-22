import 'package:flutter/material.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:hackathlone_app/models/user/anonymous.dart';
import 'package:hackathlone_app/utils/storage.dart';
import 'package:hackathlone_app/utils/cache_consent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathlone_app/services/auth_service.dart';
import 'package:hackathlone_app/services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final NotificationService _notificationService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _userProfile;
  bool _isAnonymous = false;

  AuthProvider({
    AuthService? authService,
    NotificationService? notificationService,
  }) : _authService = authService ?? AuthService(),
       _notificationService =
           notificationService ??
           NotificationService(Supabase.instance.client) {
    _user = _authService.getCurrentUser();
    _authService.authStateChanges.listen((AuthState state) {
      _user = state.session?.user;
      // Only auto-load profile if user already has a session (not during email confirmation)
      if (_user != null && _userProfile == null && !_isAnonymous) {
        _loadUserProfile();
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null && !_isAnonymous;
  bool get isAnonymous => _isAnonymous;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadUserProfile() async {
    if (_user == null) {
      return;
    }
    try {
      _clearError();

      // Check if cache is stale and needs refresh
      final isCacheStale = await _authService.isCachedProfileStale(_user!.id);
      print('🔍 AuthProvider: Cache stale check result: $isCacheStale');

      UserProfile? profile;

      if (isCacheStale) {
        // Cache is stale or missing, fetch fresh from database
        print('🌐 AuthProvider: Fetching fresh profile from database');
        profile = await _authService.fetchUserProfile(_user!.id);
        print(
          '✅ AuthProvider: Fresh profile fetched, QR Code: ${profile.qrCode}',
        );
      } else {
        // Cache is current, use cached profile
        print('💾 AuthProvider: Using current cached profile');
        try {
          profile = HackCache.getUserProfile(_user!.id);
          print('📱 AuthProvider: Cached profile QR Code: ${profile?.qrCode}');
        } catch (cacheError) {
          print(
            '⚠️ AuthProvider: Cache read failed: $cacheError, fetching fresh',
          );
          profile = await _authService.fetchUserProfile(_user!.id);
          print(
            '🔄 AuthProvider: Fresh fetch after cache error, QR Code: ${profile.qrCode}',
          );
        }
      }

      // Validate we have a profile
      if (profile != null) {
        _userProfile = profile;
        print(
          '🎯 AuthProvider: Profile loaded successfully, QR Code: ${_userProfile?.qrCode}',
        );
      } else {
        // If no profile found, try to fetch fresh from database as fallback
        print('⚠️ AuthProvider: No profile found, attempting fresh fetch');
        _userProfile = await _authService.fetchUserProfile(_user!.id);
        print(
          '🔄 AuthProvider: Fallback fetch completed, QR Code: ${_userProfile?.qrCode}',
        );
      }

      notifyListeners();
    } catch (e) {
      print('❌ AuthProvider: Error loading profile: $e');

      // Final fallback: try to use any cached profile available
      try {
        final cachedProfile = HackCache.getUserProfile(_user!.id);
        if (cachedProfile != null) {
          _userProfile = cachedProfile;
          print('🚨 AuthProvider: Using cached profil e as emergency fallback');
          print(
            '📱 AuthProvider: Emergency fallback QR Code: ${_userProfile?.qrCode}',
          );
          notifyListeners();
        } else {
          print('💥 AuthProvider: No cached profile available for fallback');
          _setError('Failed to load user profile');
        }
      } catch (cacheError) {
        print('💀 AuthProvider: Cache fallback also failed: $cacheError');
        print('🔄 AuthProvider: Attempting final fresh fetch');
        try {
          _userProfile = await _authService.fetchUserProfile(_user!.id);
          print(
            '✅ AuthProvider: Final fresh fetch successful, QR Code: ${_userProfile?.qrCode}',
          );
          notifyListeners();
        } catch (finalError) {
          print('💀 AuthProvider: All fallbacks failed: $finalError');
          _setError('Failed to load user profile');
        }
      }
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    final result = await _authService.signUp(email: email, password: password);
    _setLoading(false);
    if (result != null) {
      _setError(result);
    }
    return result;
  }

  Future<String?> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _setLoading(true);

    // Exit anonymous mode if active
    if (_isAnonymous) {
      await _exitAnonymousMode();
    }

    final result = await _authService.signIn(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
    _setLoading(false);
    if (result != null) {
      _setError(result);
    } else {
      _user = _authService.getCurrentUser();

      // Set cache consent based on remember me preference
      if (_user != null) {
        await CacheConsent.setConsent(rememberMe, _user!.id);
        print('🔐 Cache consent set to: $rememberMe for user: ${_user!.id}');
      }

      // Load user profile with cache validation
      if (_user != null) {
        try {
          await _loadUserProfile(); // This now uses cache validation

          // Initialize FCM token for push notifications (only for consenting users)
          if (rememberMe) {
            await _initializeFCMToken();
          }
        } catch (e) {
          _setError('Failed to load profile: $e');
        }
      }

      notifyListeners();
    }
    return result;
  }

  Future<String?> resetPassword({required String email}) async {
    _setLoading(true);
    final result = await _authService.resetPassword(email: email);
    _setLoading(false);
    if (result != null) {
      _setError(result);
    }
    return result;
  }

  Future<String?> verifyOtp({
    required String email,
    required String token,
    required String type,
    String? password,
  }) async {
    _setLoading(true);
    final result = await _authService.verifyOtp(
      email: email,
      token: token,
      type: type,
      password: password,
    );
    _setLoading(false);
    if (result != null) {
      _setError(result);
    } else {
      _user = _authService.getCurrentUser();

      // safety measure to ensure FCM token is initialized incase user bypasss onboarding flow
      if (type == 'signup' && _user != null) {
        print(
          '🔐 AuthProvider: Signup verified, ensuring FCM token initialization',
        );
        await _initializeFCMToken();
      }

      notifyListeners();
    }
    return result;
  }

  Future<String?> signOut() async {
    _setLoading(true);

    // Check if user had consent before signing out
    final hadConsent = await CacheConsent.hasConsent();

    final result = await _authService.signOut();
    _setLoading(false);
    if (result != null) {
      print('Sign out error: $result');
      _setError(result);
    } else {
      _user = null;
      _userProfile = null;

      // Clear cache if user didn't have consent (or revoke consent)
      if (!hadConsent) {
        await HackCache.clearUserCache();
        await CacheConsent.setConsent(false, null);
        print('🧹 Cache cleared - user had no consent');
      }

      notifyListeners();
    }
    return result;
  }

  /// Switch to anonymous/guest mode
  Future<void> switchToAnonymousMode() async {
    print('👤 Switching to anonymous mode');
    _isAnonymous = true;
    _user = null;
    _userProfile = AnonymousUser.createProfile();
    await CacheConsent.setAnonymousMode(true);

    // Clear any existing cache and consent
    await HackCache.clearUserCache();
    await CacheConsent.setConsent(false, null);

    notifyListeners();
  }

  /// Exit anonymous mode (private method)
  Future<void> _exitAnonymousMode() async {
    if (_isAnonymous) {
      print('👤 Exiting anonymous mode');
      _isAnonymous = false;
      _userProfile = null;
      await CacheConsent.setAnonymousMode(false);
      notifyListeners();
    }
  }

  /// Check if user can access a specific feature
  bool canAccessFeature(String feature) {
    if (_isAnonymous) {
      return AnonymousUser.canAccessFeature(feature);
    }
    return true; // Authenticated users can access all features
  }

  /// Get upgrade message for restricted features (anonymous users)
  String getUpgradeMessage(String feature) {
    return AnonymousUser.getUpgradeMessage(feature);
  }

  /// Check cache consent status
  Future<bool> hasCacheConsent() async {
    return await CacheConsent.hasConsent();
  }

  /// Set cache consent manually (for settings page)
  Future<void> setCacheConsent(bool consent) async {
    if (_user != null) {
      await CacheConsent.setConsent(consent, _user!.id);
      if (!consent) {
        // If revoking consent, clear cache
        await HackCache.clearUserCache(_user!.id);
      }
      print('⚙️ Cache consent manually set to: $consent');
    }
  }

  Future<bool> emailExists(String email) async {
    return await _authService.emailExists(email);
  }

  Future<Map<String, dynamic>> loadCredentials() async {
    return await _authService.loadCredentials();
  }

  /// Update user profile (for onboarding and profile editing)
  Future<void> updateUserProfile({
    String? fullName,
    String? jobRole,
    String? tshirtSize,
    String? dietaryPreferences,
    List<String>? skills,
    String? bio,
    String? phone,
    String? avatarUrl,
    bool isOnboarding = false,
  }) async {
    if (_user == null || _isAnonymous)
      throw Exception('User not authenticated');

    _setLoading(true);
    try {
      final updatedProfile = await _authService.updateUserProfile(
        userId: _user!.id,
        fullName: fullName,
        jobRole: jobRole,
        tshirtSize: tshirtSize,
        dietaryPreferences: dietaryPreferences,
        skills: skills,
        bio: bio,
        phone: phone,
        avatarUrl: avatarUrl,
        isOnboarding: isOnboarding, // ✅ Pass the onboarding flag
      );

      // Update local profile and notify listeners
      _userProfile = updatedProfile;

      // For onboarding, set cache consent and initialize FCM
      if (isOnboarding) {
        // Grant cache consent for onboarding users
        await CacheConsent.setConsent(true, _user!.id);
        print('✅ Cache consent granted during onboarding');

        // Initialize FCM token after profile update
        await _initializeFCMToken();

        // Send welcome notification
        await _notificationService.sendWelcomeNotification(_user!.id);
      }

      // Force cache refresh since profile was updated
      print('🔄 AuthProvider: Profile updated, refreshing cache');
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: $e');
      throw Exception('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Force refresh user profile from database (admin feature)
  Future<void> forceRefreshProfile() async {
    if (_user == null) throw Exception('User not authenticated');

    print('🔄 AuthProvider: Force refreshing profile for user ${_user!.id}');
    _setLoading(true);
    try {
      _userProfile = await _authService.fetchUserProfile(_user!.id);
      print(
        '🔄 AuthProvider: Force refresh completed, QR Code: ${_userProfile?.qrCode}',
      );
      notifyListeners();
    } catch (e) {
      print('❌ AuthProvider: Force refresh failed: $e');
      _setError('Failed to refresh profile: $e');
      throw Exception('Failed to refresh profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load user profile (public method for external calls)
  Future<void> loadUserProfile() async {
    await _loadUserProfile();
  }

  /// Get user role from profile
  String? get userRole => _userProfile?.role;

  /// Check if user is admin
  bool get isAdmin => userRole?.toLowerCase() == 'admin';

  /// Initialize FCM token for push notifications (only for consenting users)
  Future<void> _initializeFCMToken() async {
    if (_user == null || _isAnonymous) return;

    // Only initialize FCM token if user has given consent
    final hasConsent = await CacheConsent.hasConsent();
    if (!hasConsent) {
      print('🚫 FCM token initialization skipped - no user consent');
      return;
    }

    try {
      await _notificationService.initializeFCMToken(_user!.id);
      print('🔔 AuthProvider: FCM token initialized successfully');
    } catch (e) {
      print('❌ AuthProvider: Failed to initialize FCM token: $e');
      // Don't throw error as this shouldn't break the login flow
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
