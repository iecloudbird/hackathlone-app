import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/screens/onboarding/controller.dart';
import 'package:hackathlone_app/common/widgets/auth_field.dart';
import 'package:hackathlone_app/common/widgets/custom_dropdown.dart';
import 'package:hackathlone_app/common/widgets/multi_select_dropdown.dart';
import 'package:hackathlone_app/common/widgets/auth_button.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/core/decorations.dart';
import 'package:hackathlone_app/core/constants/constants.dart';
import 'package:hackathlone_app/router/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final OnboardingController _controller = OnboardingController();
  bool _isCheckingProfile = false;
  bool _isUpdatingProfile = false;

  @override
  void initState() {
    super.initState();
    _ensureProfileIsReady();
  }

  Future<void> _ensureProfileIsReady() async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      context.go(AppRoutes.login);
      return;
    }

    // if no profile loaded, try to load it
    if (authProvider.userProfile == null) {
      setState(() {
        _isCheckingProfile = true;
      });

      try {
        print('🔄 Onboarding: No profile found, attempting to load...');
        await authProvider.loadUserProfile();
        print('✅ Onboarding: Profile loaded successfully');
      } catch (e) {
        print('⚠️ Onboarding: Profile load failed, continuing anyway: $e');
        // Continue with onboarding - the updateUserProfile will handle missing profiles
      } finally {
        setState(() {
          _isCheckingProfile = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingProfile) {
      return Scaffold(
        body: Container(
          decoration: AppDecorations.backgroundGradient,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Preparing your profile...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppDecorations.backgroundGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppDimensions.paddingAll24,
            child: Form(
              key: _controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDimensions.verticalSpaceXL,
                  Center(
                    child: Image.asset(
                      AppAssets.motif,
                      height: 120,
                      width: 120,
                    ),
                  ),
                  AppDimensions.verticalSpaceXL,

                  // Title
                  Text(
                    'Profile Info',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppDimensions.verticalSpaceL,

                  // Full Name Field
                  AuthField(
                    label: 'Name',
                    hintText: 'Your name',
                    controller: _controller.nameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  AppDimensions.verticalSpaceM,

                  // Role Dropdown
                  CustomDropdown(
                    label: 'What best describes you?',
                    value: _controller.selectedRole,
                    items: OnboardingController.roleOptions,
                    onChanged: (value) {
                      setState(() {
                        _controller.selectedRole = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select what best describes you';
                      }
                      return null;
                    },
                  ),
                  AppDimensions.verticalSpaceM,

                  // T-shirt Size Dropdown
                  CustomDropdown(
                    label: 'T-shirt Size',
                    value: _controller.selectedTshirtSize,
                    items: OnboardingController.tshirtSizeOptions,
                    onChanged: (value) {
                      setState(() {
                        _controller.selectedTshirtSize = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your t-shirt size';
                      }
                      return null;
                    },
                  ),
                  AppDimensions.verticalSpaceM,

                  // Dietary Preference Dropdown
                  CustomDropdown(
                    label: 'Dietary Preference',
                    value: _controller.selectedDietaryPreference,
                    items: OnboardingController.dietaryOptions,
                    onChanged: (value) {
                      setState(() {
                        _controller.selectedDietaryPreference = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your dietary preference';
                      }
                      return null;
                    },
                  ),
                  AppDimensions.verticalSpaceM,

                  // Skills Multi-Select Dropdown
                  MultiSelectDropdown(
                    label: 'Your skillsets (max 5)',
                    selectedItems: _controller.selectedSkills,
                    availableItems: OnboardingController.skillOptions,
                    maxSelections: 5,
                    hintText: 'Select your skills...',
                    onChanged: (skills) {
                      setState(() {
                        _controller.selectedSkills = skills;
                      });
                    },
                    validator: (skills) {
                      if (skills == null || skills.isEmpty) {
                        return 'Please select at least one skill';
                      }
                      return null;
                    },
                  ),
                  AppDimensions.verticalSpaceXL,

                  // Continue Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return AuthButton(
                        text: 'Continue',
                        onPressed:
                            (_isUpdatingProfile || authProvider.isLoading)
                            ? null
                            : () async {
                                setState(() {
                                  _isUpdatingProfile = true;
                                });
                                await _controller.completeOnboarding(context);
                                if (mounted) {
                                  setState(() {
                                    _isUpdatingProfile = false;
                                  });
                                }
                              },
                        isLoading: _isUpdatingProfile || authProvider.isLoading,
                      );
                    },
                  ),
                  AppDimensions.verticalSpaceL,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
