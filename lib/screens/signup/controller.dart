import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathlone_app/screens/login/index.dart';

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

  Future<String?> signUp(BuildContext context, {String? token}) async {
    if (!_formKey.currentState!.validate()) return 'Validation failed';

    try {
      if (token != null) {
        // Handle invitation flow with token
        await Supabase.instance.client.auth.verifyOTP(
          email: _emailController.text.trim(),
          token: token,
          type: OtpType.invite,
        );
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
      } else {
        // Regular sign-up with email and password
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      if (context.mounted) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => const LoginPage()),
        // );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign-up failed: $e')));
      }
    }
    return null;
  }

  void navigateToSignIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}
