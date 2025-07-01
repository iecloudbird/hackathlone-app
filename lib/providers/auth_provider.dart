import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathlone_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _userProfile;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _user = _authService.getCurrentUser();
    _authService.authStateChanges.listen((AuthState state) {
      _user = state.session?.user;
      notifyListeners();
    });
  }

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
    required BuildContext context,
    required bool rememberMe,
  }) async {
    _setLoading(true);
    final result = await _authService.signIn(
      email: email,
      password: password,
      context: context,
      rememberMe: rememberMe,
    );
    _setLoading(false);
    if (result != null) {
      _setError(result);
    } else {
      _user = _authService.getCurrentUser();

      // Load user profile, use cached profile: TODO check cache profiles exist on GStorage
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

  Future<String?> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    _setLoading(true);
    final result = await _authService.resetPassword(
      email: email,
      context: context,
    );
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
    required BuildContext context,
  }) async {
    _setLoading(true);
    final result = await _authService.verifyOtp(
      email: email,
      token: token,
      type: type,
      password: password,
      context: context,
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

  Future<String?> signOut(BuildContext context) async {
    _setLoading(true);
    final result = await _authService.signOut(context);
    _setLoading(false);
    if (result != null) {
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
