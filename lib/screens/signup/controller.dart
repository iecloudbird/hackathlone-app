import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathlone_app/router/app_routes.dart';

class SignUpPageController {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  GlobalKey<FormState> get formKey => _formKey;

  /// query auth.users via Supabase admin API (requires service role key)
  /// Alternatively, query profiles table (safer for client-side)
  Future<bool> emailExisted(String email) async {
    try {
      final response = await Supabase.instance.client
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

  Future<String?> signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return 'Validation failed';

    final email = _emailController.text.trim();

    // Check if email already exists
    final emailExists = await emailExisted(email);
    if (emailExists) {
      return 'This email is already registered. Please sign in or use a different email.';
    }

    try {
      final signUpResponse = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        emailRedirectTo: 'https://www.hackathlone.com/auth_action?type=signup',
      );

      if (signUpResponse.user == null) {
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

        context.go(AppRoutes.login);
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        String errorMessage;
        switch (e.statusCode) {
          case '400':
            errorMessage = 'Invalid email or password. Please try again.';
          case '422':
            errorMessage =
                'Email already in use or invalid. Please use a different email.';
          default:
            errorMessage = 'Sign-up failed: ${e.message} ${e.statusCode}';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return e.message;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
      return e.toString();
    }
    return null;
  }

  void navigateToSignIn(BuildContext context) {
    context.go(AppRoutes.login);
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}
