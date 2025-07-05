import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: 'https://www.hackathlone.com/auth_action?type=signup',
      );

      if (response.user == null) {
        return 'Sign-up failed. Please check your email and try again.';
      }
      return null;
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.statusCode) {
        case '400':
          errorMessage = 'Invalid email or password. Please try again.';
        case '422':
          errorMessage =
              'Email already in use or invalid. Please use a different email.';
        default:
          errorMessage = 'Sign-up failed: ${e.message} (${e.statusCode})';
      }
      return errorMessage;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> resetPassword({required String email}) async {
    if (email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }

    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'https://www.hackathlone.com/auth_action?type=recovery',
      );
      return null;
    } on AuthException catch (e) {
      return 'Failed to send reset email: ${e.message} (${e.statusCode})';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Verifies OTP for signup or password reset, updating password when type is 'recovery'.
  Future<String?> verifyOtp({
    required String email,
    required String token,
    required String type,
    String? password,
  }) async {
    try {
      await _client.auth.verifyOTP(
        token: token,
        type: type == 'signup' ? OtpType.signup : OtpType.recovery,
        email: email.trim(),
      );

      if (type == 'recovery' && password != null) {
        await _client.auth.updateUser(UserAttributes(password: password));
      }
      return null;
    } on AuthException catch (e) {
      return 'Failed to process: ${e.message} (Status: ${e.statusCode}, Code: ${e.code})';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      final response = await _client
          .from('profiles')
          .select('email')
          .eq('email', email.trim())
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('Error checking email existence: $e');
      return false;
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) {
        return 'Sign-in failed. Please check your credentials.';
      }
      return null;
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        await _client.auth.resend(
          type: OtpType.signup,
          email: email.trim(),
          emailRedirectTo:
              'https://www.hackathlone.com/auth_action?type=signup',
        );
        return 'Email not confirmed. A new confirmation email has been sent.';
      }
      return e.code == 'invalid_credentials'
          ? 'Invalid email or password'
          : 'Sign-in failed: ${e.message} (${e.statusCode})';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> saveCredentials(String email, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', email.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('email');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<Map<String, dynamic>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final rememberMe = prefs.getBool('remember_me') ?? false;
    return {'email': savedEmail, 'rememberMe': rememberMe};
  }

  Future<String?> signOut() async {
    try {
      await _client.auth.signOut();
      await saveCredentials('', false); // clear credentials
      return null;
    } catch (e) {
      return 'Failed to sign out: $e';
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, email, full_name, qr_code, role')
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  User? getCurrentUser() => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
