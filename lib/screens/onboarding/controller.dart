import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/core/notice.dart';

class OnboardingController {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? selectedRole;
  String? selectedTshirtSize;
  String? selectedDietaryPreference;
  List<String> selectedSkills = [];

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get nameController => _nameController;

  // Role options
  static const List<String> roleOptions = [
    'Designer',
    'Developer',
    'Product Manager',
    'Data Scientist',
    'Student',
    'Entrepreneur',
    'Other',
  ];

  // T-shirt size options
  static const List<String> tshirtSizeOptions = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
  ];

  // Dietary preference options
  static const List<String> dietaryOptions = [
    'No Preference',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Halal',
    'Kosher',
    'Dairy-Free',
    'Nut Allergy',
    'Other',
  ];

  // Skill options
  static const List<String> skillOptions = [
    'Frontend Development',
    'Backend Development',
    'Mobile Development',
    'UI/UX Design',
    'Data Science',
    'Machine Learning',
    'DevOps',
    'Product Management',
    'Marketing',
    'Business Development',
    'Graphic Design',
    'Project Management',
    'API Development',
    'Database Design',
    'Cloud Computing',
    'Cybersecurity',
    'Quality Assurance',
    'Game Development',
    'Blockchain',
    'IoT',
  ];

  Future<void> completeOnboarding(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation for required fields
    if (selectedRole == null || selectedRole!.isEmpty) {
      showSnackBar(context, 'Please select what best describes you');
      return;
    }

    if (selectedTshirtSize == null || selectedTshirtSize!.isEmpty) {
      showSnackBar(context, 'Please select your t-shirt size');
      return;
    }

    if (selectedDietaryPreference == null ||
        selectedDietaryPreference!.isEmpty) {
      showSnackBar(context, 'Please select your dietary preference');
      return;
    }

    if (selectedSkills.isEmpty) {
      showSnackBar(context, 'Please select at least one skill');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter your name');
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();

      print('🚀 Starting onboarding update with:');
      print('  - Full Name: "${_nameController.text.trim()}"');
      print('  - Job Role: "$selectedRole"');
      print('  - T-shirt Size: "$selectedTshirtSize"');
      print('  - Dietary Preferences: "$selectedDietaryPreference"');
      print('  - Skills: $selectedSkills');

      // Update user profile with onboarding data
      await authProvider.updateUserProfile(
        fullName: _nameController.text.trim(),
        jobRole: selectedRole!,
        tshirtSize: selectedTshirtSize!,
        dietaryPreferences: selectedDietaryPreference!,
        skills: selectedSkills,
      );

      print('✅ Onboarding update completed successfully');

      if (context.mounted) {
        showSuccessSnackBar(context, 'Profile created successfully!');
        context.go(AppRoutes.home);
      }
    } catch (e) {
      print('❌ Onboarding update failed: $e');
      if (context.mounted) {
        showSnackBar(context, 'Failed to create profile: $e');
      }
    }
  }

  void dispose() {
    _nameController.dispose();
  }
}
