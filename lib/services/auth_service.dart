import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/router/app_routes.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Signs up a user with email and password.
  /// Returns null on success, error message on failure.
  Future<String?> signUp({
    required String email,
    required String password,
    required BuildContext context,
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sign-up successful! Please check your email to verify your account.',
            ),
          ),
        );
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
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return errorMessage;
    } catch (e) {
      final errorMessage = 'Unexpected error: $e';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return errorMessage;
    }
  }

  /// Sends a password reset email.
  /// Returns null on success, error message on failure.
  Future<String?> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
      return null;
    } on AuthException catch (e) {
      final errorMessage =
          'Failed to send reset email: ${e.message} (${e.statusCode})';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return errorMessage;
    } catch (e) {
      final errorMessage = 'Unexpected error: $e';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return errorMessage;
    }
  }

  /// Verifies OTP for signup or password reset.
  /// Updates password if type is recovery.
  /// Returns null on success, error message on failure.
  Future<String?> verifyOtp({
    required String email,
    required String token,
    required String type,
    String? password,
    required BuildContext context,
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type == 'signup'
                  ? 'Email confirmed successfully'
                  : 'Password updated successfully',
            ),
          ),
        );
      }
      return null;
    } on AuthException catch (e) {
      final errorMessage =
          'Failed to process: ${e.message} (Status: ${e.statusCode}, Code: ${e.code})';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return errorMessage;
    } catch (e) {
      final errorMessage = 'Unexpected error: $e';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return errorMessage;
    }
  }

  /// Checks if an email is already registered.
  /// Returns true if email exists, false otherwise.
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
      return false; // Assume email doesn't exist if check fails
    }
  }

  /// Signs in a user with email and password.
  /// Returns null on success, error message on failure.
  Future<String?> signIn({
    required String email,
    required String password,
    required BuildContext context,
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
      await saveCredentials(email, rememberMe);
      if (context.mounted) {
        context.go(AppRoutes.home);
        return null;
      }
      return 'Navigation error';
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        await _client.auth.resend(
          type: OtpType.signup,
          email: email.trim(),
          emailRedirectTo:
              'https://www.hackathlone.com/auth_action?type=signup',
        );
        final errorMessage =
            'Email not confirmed. A new confirmation email has been sent.';
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
        return errorMessage;
      }
      final errorMessage = e.code == 'invalid_credentials'
          ? 'Invalid email or password'
          : 'Sign-in failed: ${e.message} (${e.statusCode})';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return errorMessage;
    } catch (e) {
      final errorMessage = 'Unexpected error: $e';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return errorMessage;
    }
  }

  /// Saves email and remember me state to SharedPreferences.
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

  /// Loads saved email and remember me state from SharedPreferences.
  Future<Map<String, dynamic>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final rememberMe = prefs.getBool('remember_me') ?? false;
    return {'email': savedEmail, 'rememberMe': rememberMe};
  }

  /// Signs out the current user and clears saved credentials.
  /// Returns null on success, error message on failure.
  Future<String?> signOut(BuildContext context) async {
    try {
      await _client.auth.signOut();
      await saveCredentials('', false); // Clear credentials
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
      return null;
    } catch (e) {
      final errorMessage = 'Failed to sign out: $e';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return errorMessage;
    }
  }

  /// Gets the current user, if any.
  User? getCurrentUser() => _client.auth.currentUser;

  /// Listens to auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
