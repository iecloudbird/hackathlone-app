import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hackathlone_app/main.dart';
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
    if (!_formKey.currentState!.validate()) return 'Validation failed';
    log('Attempting to sign in with email: ${_emailController.text.trim()}');
    log('Attempting to sign in with password: ${_passwordController.text}');

    try {
      log('Attempting to sign in with email: ${_emailController.text.trim()}');
      log('Attempting to sign in with password: ${_passwordController.text}');
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
      return null;
    } catch (e) {
      return 'Sign-in failed: ${e.toString()}';
    }
  }

  void navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
  }
}
