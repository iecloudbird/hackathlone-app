import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/core/notice.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthActionPageController {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  void togglePasswordVisibility(bool value) {
    _isPasswordVisible = value;
  }

  void toggleConfirmPasswordVisibility(bool value) {
    _isConfirmPasswordVisible = value;
  }

  Future<void> verifyOtp(
    BuildContext context,
    String action,
    String? token,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    if (token == null) {
      showSnackBar(context, 'No verification token provided');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyOtp(
      email: _emailController.text.trim(),
      token: token,
      type: action,
      password: action == 'recovery' ? _passwordController.text : null,
    );

    if (authProvider.errorMessage == null && context.mounted) {
      showSuccessSnackBar(
        context,
        action == 'signup'
            ? 'Email confirmed successfully'
            : 'Password updated successfully',
      );
      if (action == 'signup') {
        await authProvider.loadUserProfile();
        context.go(AppRoutes.onboarding);
      } else {
        context.go(AppRoutes.login);
      }
    } else if (authProvider.errorMessage != null && context.mounted) {
      showSnackBar(context, authProvider.errorMessage!);
    }
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}
