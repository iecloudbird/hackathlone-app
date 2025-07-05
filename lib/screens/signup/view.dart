import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/auth/utils.dart';
import './controller.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/common/widgets/auth_field.dart';

class SignUpPage extends StatefulWidget {
  final String? token;

  const SignUpPage({super.key, this.token});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const imageLogo = AssetImage('assets/images/motif.png');
  final controller = SignUpPageController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).viewInsets.bottom,
              ),
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
                    const Text(
                      'Create your account',
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
                              label: 'Email',
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (email) => Auth.validateEmail(email),
                            ),
                            const SizedBox(height: 16),
                            AuthField(
                              label: 'Password',
                              controller: controller.passwordController,
                              obscureText: true,
                              enableVisibilityToggle: true,
                              isVisible: _isPasswordVisible,
                              onVisibilityChanged: (visible) {
                                setState(() {
                                  _isPasswordVisible = visible;
                                });
                              },
                              validator: (password) =>
                                  Auth.validatePassword(password),
                            ),
                            const SizedBox(height: 16),
                            AuthField(
                              label: 'Confirm Password',
                              controller: controller.confirmPasswordController,
                              obscureText: true,
                              enableVisibilityToggle: true,
                              isVisible: _isConfirmPasswordVisible,
                              onVisibilityChanged: (visible) {
                                setState(() {
                                  _isConfirmPasswordVisible = visible;
                                });
                              },
                              validator: (password) =>
                                  Auth.validateConfirmPassword(
                                    password,
                                    controller.passwordController.text,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
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
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        setState(() => _isLoading = true);
                                        _errorMessage = null;
                                        setState(() => _isLoading = false);
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
                                        'Sign Up',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: _isLoading
                                        ? null
                                        : () => controller.navigateToSignIn(
                                            context,
                                          ),
                                    child: const Text(
                                      'Sign In',
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
