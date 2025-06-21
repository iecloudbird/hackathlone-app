import 'package:flutter/material.dart';
import 'package:hackathlone_app/screens/home/view.dart';
import 'package:hackathlone_app/screens/signup/view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPageController {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  GlobalKey<FormState> get formKey => _formKey;

  // Load saved email and remember me state
  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final rememberMe = prefs.getBool('remember_me') ?? false;
    if (savedEmail != null && rememberMe) {
      _emailController.text = savedEmail;
    }
  }

  // Save email once app closed
  Future<void> saveCredentials(String email, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', email);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('email');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<String?> signIn(
    BuildContext context, {
    required bool rememberMe,
  }) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_formKey.currentState!.validate()) {
      return 'Please fix the errors above';
    }

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Save credentials if "Remember Me" is checked
      await saveCredentials(email, rememberMe);
      if (context.mounted) {
        navigateToHomePage(context);
        return null;
      }
      return 'Navigation error';
    } on AuthException catch (e) {
      //TO-DO: set timeout for resend and limit resend attempts
      if (e.message.contains('Email not confirmed')) {
        await Supabase.instance.client.auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: 'com.hackathlone.app://auth_action?type=signup',
        );
        return 'Email not confirmed. A new confirmation email has been sent.';
      }

      if (e.code == 'invalid_credentials') {
        return 'Invalid email or password';
      }
      return 'Sign-in failed: ${e.message} ${e.statusCode}';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> resetPassword(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo:
            'com.hackathlone.app://auth_action?type=recovery', // Deep link for password reset
      );
      return null; // Success returns
    } catch (e) {
      return 'Failed to send reset email: $e';
    }
  }

  void navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
  }
}
