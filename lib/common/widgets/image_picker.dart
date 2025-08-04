import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:hackathlone_app/core/theme.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;
  final double size;
  final bool showEditIcon;
  final bool isEditable;

  const ProfileImagePicker({
    super.key,
    this.imageUrl,
    this.onTap,
    this.size = 80,
    this.showEditIcon = false,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: imageUrl != null
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.electricBlue, AppColors.brightYellow],
                    ),
              border: Border.all(
                color: AppColors.brightYellow.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          if (showEditIcon && isEditable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.brightYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.deepBlue, width: 2),
                ),
                child: Icon(
                  IconsaxPlusLinear.edit,
                  size: 12,
                  color: AppColors.deepBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.electricBlue, AppColors.brightYellow],
        ),
      ),
      child: Icon(
        IconsaxPlusBold.profile,
        color: AppColors.deepBlue,
        size: size * 0.4,
      ),
    );
  }
}
