import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // if (token != null) {
      // Handle invitation flow with token
      // final otpResponse = await Supabase.instance.client.auth.verifyOTP(
      //   email: email,
      //   token: token,
      //   type: OtpType.invite,
      // );

      // if (otpResponse.user != null) {
      //   //Update user with password, this is placeholder and will move forward to onboarding, so user will only be updated when they complete onboarding
      //   // or else cancel the sign-up
      //   await Supabase.instance.client.auth.updateUser(
      //     UserAttributes(password: password),
      //   );
      // } else {
      //   return 'Invalid or expired invitation token.';
      // }
      // } else {
      // Regular sign-up with email and password
      final signUpResponse = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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

        Navigator.pushReplacementNamed(context, '/login');
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        String errorMessage;
        switch (e.statusCode) {
          case '400':
            errorMessage = 'Invalid email or password. Please try again.';
            break;
          case '422':
            errorMessage =
                'Email already in use or invalid. Please use a different email.';
            break;
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
    Navigator.pushReplacementNamed(context, '/signup');
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}
