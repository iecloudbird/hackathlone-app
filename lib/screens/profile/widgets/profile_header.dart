import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/constants.dart';
import 'package:hackathlone_app/models/user/profile.dart';
import 'package:hackathlone_app/common/widgets/image_picker.dart';
import 'package:hackathlone_app/common/widgets/auth_field.dart';

/// Widget for displaying and editing profile header information
class ProfileHeader extends StatelessWidget {
  final UserProfile userProfile;
  final bool isEditing;
  final TextEditingController? nameController;
  final VoidCallback? onAvatarTap;
  final String? Function(String?)? nameValidator;

  const ProfileHeader({
    super.key,
    required this.userProfile,
    required this.isEditing,
    this.nameController,
    this.onAvatarTap,
    this.nameValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ProfileImagePicker(
            imageUrl: userProfile.avatarUrl,
            size: 100,
            showEditIcon: isEditing,
            isEditable: isEditing,
            onTap: isEditing ? onAvatarTap : null,
          ),
          AppDimensions.verticalSpaceM,
          if (isEditing && nameController != null)
            SizedBox(
              width: double.infinity,
              child: AuthField(
                label: 'Full Name',
                controller: nameController!,
                validator: nameValidator,
              ),
            )
          else
            Text(
              userProfile.fullName,
              style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          AppDimensions.verticalSpaceS,
          Text(
            userProfile.jobRole ?? 'No job role specified',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.brightYellow,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
