import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/common/widgets/auth_field.dart';
import 'package:hackathlone_app/screens/auth/controller.dart';
import 'package:hackathlone_app/core/auth/utils.dart';

class AuthActionPage extends StatefulWidget {
  final String action; // 'recovery' or 'signup'
  final String? token; // token from deep link

  const AuthActionPage({super.key, required this.action, this.token});

  @override
  State<AuthActionPage> createState() => _AuthActionPageState();
}

class _AuthActionPageState extends State<AuthActionPage> {
  final controller = AuthActionPageController();

  @override
  void initState() {
    super.initState();
    // Try to verify OTP for signup
    if (widget.action == 'signup' && widget.token != null) {
      controller.verifyOtp(context, widget.action, widget.token);
    }
  }

  @override
  void dispose() {
    controller.dispose();
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
                    key: controller.formKey,
                    child: Column(
                      children: [
                        AuthField(
                          label: 'Email',
                          controller: controller.emailController,
                          enabled: !authProvider.isLoading,
                          keyboardType: TextInputType.emailAddress,
                          validator: (email) => Auth.validateEmail(email),
                        ),
                        if (isReset) ...[
                          const SizedBox(height: 16),
                          AuthField(
                            label: 'New Password',
                            controller: controller.passwordController,
                            enabled: !authProvider.isLoading,
                            obscureText: !controller.isPasswordVisible,
                            enableVisibilityToggle: true,
                            isVisible: controller.isPasswordVisible,
                            onVisibilityChanged:
                                controller.togglePasswordVisibility,
                            validator: (password) =>
                                Auth.validatePassword(password),
                          ),
                          const SizedBox(height: 16),
                          AuthField(
                            label: 'Confirm Password',
                            controller: controller.confirmPasswordController,
                            enabled: !authProvider.isLoading,
                            obscureText: !controller.isConfirmPasswordVisible,
                            enableVisibilityToggle: true,
                            isVisible: controller.isConfirmPasswordVisible,
                            onVisibilityChanged:
                                controller.toggleConfirmPasswordVisibility,
                            validator: (password) =>
                                Auth.validateConfirmPassword(
                                  password,
                                  controller.passwordController.text,
                                ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () => controller.verifyOtp(
                                    context,
                                    widget.action,
                                    widget.token,
                                  ),
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
