import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/core/notice.dart';

class LoginPageController {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  GlobalKey<FormState> get formKey => _formKey;

  Future<void> loadSavedCredentials() async {
    final authProvider = AuthProvider();
    final credentials = await authProvider.loadCredentials();
    final savedEmail = credentials['email'] as String?;
    final rememberMe = credentials['rememberMe'] as bool;
    if (savedEmail != null && rememberMe) {
      _emailController.text = savedEmail;
    }
  }

  Future<String?> signIn(
    BuildContext context, {
    required bool rememberMe,
  }) async {
    if (!_formKey.currentState!.validate()) {
      return 'Please fix the errors above';
    }

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: rememberMe,
    );

    if (result == null && context.mounted) {
      showSuccessSnackBar(context, 'Sign-in successful!');
      context.go(AppRoutes.home);
    } else if (result != null && context.mounted) {
      showSnackBar(context, result);
    }
    return result;
  }

  Future<String?> resetPassword(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.resetPassword(
      email: _emailController.text.trim(),
    );

    if (context.mounted) {
      if (result == null) {
        showSuccessSnackBar(context, 'Password reset email sent');
      } else {
        showSnackBar(context, result);
      }
    }
    return result;
  }

  void navigateToSignUp(BuildContext context) {
    context.go(AppRoutes.signup);
  }

  void navigateToHomePage(BuildContext context) {
    context.go(AppRoutes.home);
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
  }
}
