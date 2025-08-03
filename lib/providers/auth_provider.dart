import 'package:flutter/material.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:hackathlone_app/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathlone_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _userProfile;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _user = _authService.getCurrentUser();
    _authService.authStateChanges.listen((AuthState state) {
      _user = state.session?.user;
      if (_user != null) _loadUserProfile();
      notifyListeners();
    });
  }

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadUserProfile() async {
    if (_user == null) {
      print('❌ AuthProvider: No authenticated user found');
      return;
    }

    print('🚀 AuthProvider: Loading profile for user ${_user!.id}');

    try {
      // Clear any previous errors
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
          print('🚨 AuthProvider: Using cached profile as emergency fallback');
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

      // Load user profile with cache validation
      if (_user != null) {
        try {
          await _loadUserProfile(); // This now uses cache validation
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
      notifyListeners();
    }
    return result;
  }

  Future<String?> signOut() async {
    _setLoading(true);
    final result = await _authService.signOut();
    _setLoading(false);
    if (result != null) {
      print('Sign out error: $result');
      _setError(result);
    } else {
      _user = null;
      notifyListeners();
    }
    return result;
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
  }) async {
    if (_user == null) throw Exception('User not authenticated');

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
      );

      _userProfile = updatedProfile;
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
