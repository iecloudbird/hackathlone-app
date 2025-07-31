import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:hackathlone_app/utils/storage.dart';
import 'package:hackathlone_app/router/app_routes.dart';
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
      if (_user != null) {
        // Use WidgetsBinding to avoid calling setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadUserProfile();
        });
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Role-based access methods for easy admin checking
  String? get userRole => _userProfile?.role;
  bool get isAdmin => _userProfile?.role.toLowerCase() == 'admin';
  bool get isUser => _userProfile?.role.toLowerCase() == 'user';
  bool get hasRole => _userProfile?.role != null;

  // Public method to load user profile
  Future<void> loadUserProfile() async {
    await _loadUserProfile();
  }

  // Force refresh profile from Supabase (bypass cache) - useful for debugging
  Future<void> forceRefreshProfile() async {
    if (_user != null) {
      try {
        print('🔄 Force refreshing profile from Supabase...');
        _userProfile = await _authService.fetchUserProfile(_user!.id);
        print('✅ Profile force refreshed from Supabase');
        notifyListeners();
      } catch (e) {
        debugPrint('Error force refreshing user profile: $e');
        _userProfile = null;
        notifyListeners();
      }
    }
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      try {
        print(
          '🔄 AuthProvider._loadUserProfile - Loading for user: ${_user!.id}',
        );

        // Check cache first
        final cachedProfile = HackCache.getUserProfile(_user!.id);
        if (cachedProfile != null) {
          print('💾 Found cached profile:');
          print('  - Cached role: "${cachedProfile.role}"');
          print('  - Cached email: ${cachedProfile.email}');
          print('  - Cache timestamp: ${cachedProfile.updatedAt}');
        } else {
          print('❌ No cached profile found');
        }

        _userProfile =
            cachedProfile ?? await _authService.fetchUserProfile(_user!.id);

        print('✅ Final profile loaded:');
        print('  - Final role: "${_userProfile?.role}"');
        print('  - Source: ${cachedProfile != null ? 'CACHE' : 'SUPABASE'}');
      } catch (e) {
        debugPrint('Error loading user profile: $e');
        _userProfile = null;
      }
      notifyListeners();
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

  // Sign out with automatic navigation to login page
  Future<String?> signOutWithNavigation(BuildContext context) async {
    _setLoading(true);
    final result = await _authService.signOut();
    _setLoading(false);
    if (result != null) {
      print('Sign out error: $result');
      _setError(result);
    } else {
      _user = null;
      notifyListeners();
      
      // Navigate to login page after sign out is complete
      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            context.go(AppRoutes.login);
          }
        });
      }
    }
    return result;
  }

  Future<bool> emailExists(String email) async {
    return await _authService.emailExists(email);
  }

  Future<Map<String, dynamic>> loadCredentials() async {
    return await _authService.loadCredentials();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
