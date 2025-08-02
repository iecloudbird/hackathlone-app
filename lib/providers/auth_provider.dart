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
    if (_user != null) {
      print('🚀 AuthProvider: Loading profile for user ${_user!.id}');

      // Check cache first
      final cachedProfile = HackCache.getUserProfile(_user!.id);
      if (cachedProfile != null) {
        print(
          '💾 AuthProvider: Found cached profile with QR: ${cachedProfile.qrCode}',
        );
        _userProfile = cachedProfile;
      } else {
        print('🌐 AuthProvider: No cache, fetching from Supabase...');
        _userProfile = await _authService.fetchUserProfile(_user!.id);
        print(
          '📥 AuthProvider: Received profile from service with QR: ${_userProfile?.qrCode}',
        );
      }

      print(
        '🎯 AuthProvider: Final userProfile QR Code: ${_userProfile?.qrCode}',
      );
      notifyListeners();
    } else {
      print('❌ AuthProvider: No authenticated user found');
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

      // Load user profile, use cached profile: TODO check cache profiles exist on HackStorage
      if (_user != null) {
        try {
          _userProfile = await _authService.fetchUserProfile(_user!.id);
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
}
