import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import './controller.dart';
import 'package:hackathlone_app/common/widgets/auth_field.dart';
import 'package:hackathlone_app/core/auth/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const imageLogo = AssetImage('assets/images/motif.png');
  final controller = LoginPageController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load saved credentials and remember me state
    controller.loadSavedCredentials().then((_) {
      setState(() {
        _rememberMe = controller.emailController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents resizing when keyboard appears
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'App Logo',
                    child: Image(image: imageLogo, width: 146, height: 146),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          fontFamily: 'Overpass',
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            children: [
                              AuthField(
                                label: 'Email address',
                                controller: controller.emailController,
                                enabled: !_isLoading,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => Auth.validateEmail(value),
                              ),
                              const SizedBox(height: 16),
                              AuthField(
                                label: 'Password',
                                controller: controller.passwordController,
                                enabled: !_isLoading,
                                obscureText: true,
                                enableVisibilityToggle: true,
                                isVisible: _isPasswordVisible,
                                onVisibilityChanged: (visible) {
                                  setState(() {
                                    _isPasswordVisible = visible;
                                  });
                                },
                                validator: (value) =>
                                    Auth.validatePassword(value),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Checkbox.adaptive(
                                          visualDensity: VisualDensity.compact,
                                          value: _rememberMe,
                                          onChanged: _isLoading
                                              ? null
                                              : (value) {
                                                  setState(() {
                                                    _rememberMe =
                                                        value ?? false;
                                                  });
                                                },
                                          activeColor: AppColors.electricBlue,
                                          checkColor: Colors.white,
                                        ),
                                        const Text(
                                          'Remember me',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () async {
                                                final error = await controller
                                                    .resetPassword(context);
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        error ??
                                                            'A password reset email has been sent.',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          error != null
                                                          ? Colors.red
                                                          : const Color(
                                                              0xFF131212,
                                                            ).withAlpha(
                                                              (0.9 * 255)
                                                                  .toInt(),
                                                            ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      margin: EdgeInsets.only(
                                                        top: 50.0,
                                                        left: 16.0,
                                                        right: 16.0,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                        child: const Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            color: AppColors.blueYonder,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(
                                      (0.2 * 255).toInt(),
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.martianRed,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (controller.formKey.currentState!
                                              .validate()) {
                                            setState(() => _isLoading = true);
                                            final errorMessage =
                                                await controller.signIn(
                                                  context,
                                                  rememberMe: _rememberMe,
                                                );
                                            setState(() {
                                              _isLoading = false;
                                              _errorMessage = errorMessage;
                                            });
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.electricBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.0,
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => controller.navigateToHomePage(context),
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Need an account? ',
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () => controller.navigateToSignUp(context),
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: AppColors.blueYonder,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
