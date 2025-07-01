import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/common/widgets/auth_field.dart';

class AuthActionPage extends StatefulWidget {
  final String action; // 'recovery' or 'signup'
  final String? token; // token from deep link

  const AuthActionPage({super.key, required this.action, this.token});

  @override
  State<AuthActionPage> createState() => _AuthActionPageState();
}

class _AuthActionPageState extends State<AuthActionPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Automatically verify OTP for signup
    if (widget.action == 'signup' && widget.token != null) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No verification token provided')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyOtp(
      email: _emailController.text.trim(),
      token: widget.token!,
      type: widget.action,
      password: widget.action == 'recovery' ? _passwordController.text : null,
      context: context,
    );

    if (authProvider.errorMessage == null && mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isReset = widget.action == 'recovery';

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF000613), Color(0xFF030B21), Color(0xFF040D22)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isReset ? 'Reset Your Password' : 'Confirm Your Email',
                    style: const TextStyle(
                      fontFamily: 'Overpass',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isReset
                        ? 'Enter your email and new password to reset your account.'
                        : 'Enter your email to confirm your account.',
                    style: const TextStyle(
                      fontFamily: 'Overpass',
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (authProvider.errorMessage != null) ...[
                    Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthField(
                          label: 'Email',
                          controller: _emailController,
                          enabled: !authProvider.isLoading,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        if (isReset) ...[
                          const SizedBox(height: 16),
                          AuthField(
                            label: 'New Password',
                            controller: _passwordController,
                            enabled: !authProvider.isLoading,
                            obscureText: true,
                            enableVisibilityToggle: true,
                            isVisible: _isPasswordVisible,
                            onVisibilityChanged: (visible) {
                              setState(() {
                                _isPasswordVisible = visible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AuthField(
                            label: 'Confirm Password',
                            controller: _confirmPasswordController,
                            enabled: !authProvider.isLoading,
                            obscureText: true,
                            enableVisibilityToggle: true,
                            isVisible: _isConfirmPasswordVisible,
                            onVisibilityChanged: (visible) {
                              setState(() {
                                _isConfirmPasswordVisible = visible;
                              });
                            },
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    isReset
                                        ? 'Update Password'
                                        : 'Confirm Email',
                                    style: const TextStyle(
                                      fontFamily: 'Overpass',
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
