import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/constants.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/screens/profile/widgets/header.dart';
import 'package:hackathlone_app/screens/profile/widgets/information_section.dart';
import 'package:hackathlone_app/screens/profile/widgets/utilities_section.dart';
import 'package:hackathlone_app/screens/profile/controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isLoading = false;

  // Controllers for edit mode
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String? _selectedJobRole;
  late String? _selectedTshirtSize;
  late String? _selectedDietaryPreference;
  late List<String> _selectedSkills;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final userProfile = ProfileController.getCurrentUserProfile(context);

    _nameController = TextEditingController(text: userProfile?.fullName ?? '');
    _emailController = TextEditingController(text: userProfile?.email ?? '');
    _selectedJobRole = userProfile?.jobRole;
    _selectedTshirtSize = userProfile?.tshirtSize;
    _selectedDietaryPreference = userProfile?.dietaryPreferences;
    _selectedSkills = List<String>.from(userProfile?.skills ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Handles profile save operation
  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await ProfileController.updateProfile(
        context: context,
        fullName: _nameController.text.trim(),
        jobRole: _selectedJobRole,
        tshirtSize: _selectedTshirtSize,
        dietaryPreferences: _selectedDietaryPreference,
        skills: _selectedSkills,
      );

      if (success) {
        setState(() => _isEditing = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Toggles edit mode and resets form if canceling
  void _handleToggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers if canceling edit
        _initializeControllers();
      }
    });
  }

  /// Handles sign out action
  Future<void> _handleSignOut() async {
    await ProfileController.signOut(context);
  }

  /// Handles QR code display
  void _handleShowQrCode() {
    ProfileController.showUserQrCode(context);
  }

  /// Handles avatar tap action
  void _handleAvatarTap() {
    ProfileController.handleAvatarTap(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userProfile = authProvider.userProfile;

        if (userProfile == null) {
          return Scaffold(
            backgroundColor: AppColors.deepBlue,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000613),
                    Color(0xFF030B21),
                    Color(0xFF040D22),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.electricBlue),
              ),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              // Check if we can pop back, otherwise go to home
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.pushReplacement(AppRoutes.home);
              }
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.deepBlue,
            appBar: _buildAppBar(),
            body: _buildBody(userProfile),
          ),
        );
      },
    );
  }

  /// Builds the app bar with edit/save controls
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(IconsaxPlusLinear.arrow_left, color: Colors.white),
        onPressed: () {
          // Check if we can pop back, otherwise go to home
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
      actions: [
        if (!_isEditing)
          TextButton.icon(
            onPressed: _handleToggleEdit,
            icon: const Icon(
              IconsaxPlusLinear.edit,
              color: AppColors.brightYellow,
            ),
            label: Text(
              'Edit',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.brightYellow,
              ),
            ),
          ),
        if (_isEditing) ...[
          TextButton(
            onPressed: _handleToggleEdit,
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonMedium.copyWith(color: Colors.white70),
            ),
          ),
          AppDimensions.horizontalSpaceS,
          TextButton(
            onPressed: _isLoading ? null : _handleSaveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.brightYellow,
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.brightYellow,
                    ),
                  ),
          ),
        ],
        AppDimensions.horizontalSpaceS,
      ],
    );
  }

  /// Builds the main body with profile sections
  Widget _buildBody(dynamic userProfile) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF000613), Color(0xFF030B21), Color(0xFF040D22)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.paddingAll24,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Header(
                  userProfile: userProfile,
                  isEditing: _isEditing,
                  nameController: _nameController,
                  onAvatarTap: _handleAvatarTap,
                  nameValidator: ProfileController.validateFullName,
                ),
                AppDimensions.verticalSpaceXL,

                // Profile Information Section
                InformationSection(
                  userProfile: userProfile,
                  isEditing: _isEditing,
                  selectedJobRole: _selectedJobRole,
                  selectedTshirtSize: _selectedTshirtSize,
                  selectedDietaryPreference: _selectedDietaryPreference,
                  selectedSkills: _selectedSkills,
                  onJobRoleChanged: (value) {
                    setState(() => _selectedJobRole = value);
                  },
                  onTshirtSizeChanged: (value) {
                    setState(() => _selectedTshirtSize = value);
                  },
                  onDietaryPreferenceChanged: (value) {
                    setState(() => _selectedDietaryPreference = value);
                  },
                  onSkillsChanged: (skills) {
                    setState(() => _selectedSkills = skills);
                  },
                ),
                AppDimensions.verticalSpaceXL,

                // Utilities Section
                UtilitiesSection(
                  onQrCodeTap: _handleShowQrCode,
                  onSignOutTap: _handleSignOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
