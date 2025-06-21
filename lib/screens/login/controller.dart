import 'package:flutter/material.dart';
import 'package:hackathlone_app/screens/home/view.dart';
import 'package:hackathlone_app/screens/signup/view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPageController {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  GlobalKey<FormState> get formKey => _formKey;

  Future<String?> signIn(BuildContext context) async {
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
      if (context.mounted) {
        navigateToHomePage(context);
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
      return null; // Success
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
