import 'package:flutter/material.dart';
import 'package:hackathlone_app/utils/constants.dart';
import './controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const imageLogo = AssetImage('images/motif.png');
  // static const iconLogo = AssetImage('images/dayNnight.png');
  final controller = LoginPageController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'App Logo',
                    child: Image(image: imageLogo, width: 146, height: 146),
                  ),
                  // const Image(image: iconLogo, width: 48, height: 48),
                  const SizedBox(height: 32),
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Overpass',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: controller.emailController,
                    enabled: !_isLoading, // Disable input while loading
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xFF131212),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      value!.isEmpty ? 'Email is required' : null;

                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.passwordController,
                    obscureText: true,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xFF131212),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) =>
                        value!.isEmpty ? 'Password is required' : null,
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
                        style: const TextStyle(color: AppColors.martianRed),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (controller.formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              _errorMessage = await controller.signIn(context);
                              setState(() => _isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
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
                        : const Text('Sign In', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => controller.navigateToSignUp(context),
                    child: const Text(
                      'Need an account? Sign Up',
                      style: TextStyle(color: Colors.white70),
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
