import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/core/notice.dart';

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

  Future<void> signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authProvider = context.read<AuthProvider>();
    final emailExists = await authProvider.emailExists(email);

    if (emailExists && context.mounted) {
      showSnackBar(
        context,
        'This email is already registered. Please sign in or use a different email.',
      );
      return;
    }

    final result = await authProvider.signUp(email: email, password: password);

    if (context.mounted) {
      if (result == null) {
        showSuccessSnackBar(
          context,
          'Sign-up successful! Please check your email to verify.',
        );
        context.go(AppRoutes.login);
      } else {
        showSnackBar(context, result);
      }
    }
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
