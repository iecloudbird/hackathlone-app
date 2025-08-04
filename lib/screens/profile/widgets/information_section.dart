import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/constants.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:hackathlone_app/common/widgets/custom_dropdown.dart';
import 'package:hackathlone_app/common/widgets/multi_select_dropdown.dart';
import 'package:hackathlone_app/screens/onboarding/controller.dart';

class InformationSection extends StatelessWidget {
  final UserProfile userProfile;
  final bool isEditing;
  final String? selectedJobRole;
  final String? selectedTshirtSize;
  final String? selectedDietaryPreference;
  final List<String> selectedSkills;
  final ValueChanged<String?>? onJobRoleChanged;
  final ValueChanged<String?>? onTshirtSizeChanged;
  final ValueChanged<String?>? onDietaryPreferenceChanged;
  final ValueChanged<List<String>>? onSkillsChanged;

  const InformationSection({
    super.key,
    required this.userProfile,
    required this.isEditing,
    this.selectedJobRole,
    this.selectedTshirtSize,
    this.selectedDietaryPreference,
    this.selectedSkills = const [],
    this.onJobRoleChanged,
    this.onTshirtSizeChanged,
    this.onDietaryPreferenceChanged,
    this.onSkillsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Information',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
        AppDimensions.verticalSpaceM,

        // Email (Always read-only)
        _buildInfoField(
          label: 'Email',
          value: userProfile.email,
          isEditable: false,
        ),
        AppDimensions.verticalSpaceM,

        // Job Role (Edit mode only - dropdown with bright yellow theme)
        if (isEditing) ...[
          CustomDropdown(
            label: 'Job Role',
            value: selectedJobRole,
            items: OnboardingController.roleOptions,
            accentColor: AppColors.brightYellow,
            onChanged: onJobRoleChanged ?? (value) {},
          ),
          AppDimensions.verticalSpaceM,
        ],

        // Skills
        if (isEditing)
          MultiSelectDropdown(
            label: 'Skills',
            selectedItems: selectedSkills,
            availableItems: OnboardingController.skillOptions,
            maxSelections: 5,
            onChanged: onSkillsChanged ?? (value) {},
          )
        else
          _buildInfoField(
            label: 'Skills',
            value: userProfile.skills?.join(', ') ?? 'No skills specified',
            isChips: true,
          ),
        AppDimensions.verticalSpaceM,

        // T-shirt Size
        if (isEditing)
          CustomDropdown(
            label: 'T-shirt Size',
            value: selectedTshirtSize,
            items: OnboardingController.tshirtSizeOptions,
            onChanged: onTshirtSizeChanged ?? (value) {},
          )
        else
          _buildInfoField(
            label: 'T-shirt Size',
            value: userProfile.tshirtSize ?? 'Not specified',
          ),
        AppDimensions.verticalSpaceM,

        // Dietary Preferences
        if (isEditing)
          CustomDropdown(
            label: 'Dietary Preference',
            value: selectedDietaryPreference,
            items: OnboardingController.dietaryOptions,
            onChanged: onDietaryPreferenceChanged ?? (value) {},
          )
        else
          _buildInfoField(
            label: 'Dietary Preference',
            value: userProfile.dietaryPreferences ?? 'Not specified',
          ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    bool isEditable = true,
    bool isChips = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isEditable ? Colors.white70 : Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppDimensions.verticalSpaceXS,
        Container(
          width: double.infinity,
          padding: AppDimensions.paddingAll16,
          decoration: BoxDecoration(
            color: isEditable
                ? const Color(0xFF131212)
                : const Color(0xFF131212).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEditable ? Colors.white24 : Colors.white12,
            ),
          ),
          child: isChips && value != 'No skills specified' && value.isNotEmpty
              ? Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: value
                      .split(', ')
                      .where((skill) => skill.trim().isNotEmpty)
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.electricBlue.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.electricBlue.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            skill.trim(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.electricBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isEditable ? Colors.white : Colors.white60,
                  ),
                ),
        ),
      ],
    );
  }
}
