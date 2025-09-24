import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/constants.dart';
import 'package:hackathlone_app/models/mentor/mentor.dart';
import 'package:hackathlone_app/screens/home/widgets/mentor_detail_sheet.dart';

/// Compact mentor card for grid display
class CompactMentorCard extends StatelessWidget {
  final Mentor mentor;

  const CompactMentorCard({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => MentorDetailSheet.show(context, mentor),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.maastrichtBlue,
          borderRadius: AppDimensions.radiusMedium,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image and status badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Profile image
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusM),
                        topRight: Radius.circular(AppDimensions.radiusM),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusM),
                        topRight: Radius.circular(AppDimensions.radiusM),
                      ),
                      child: mentor.imageUrl != null
                          ? Image.network(
                              mentor.imageUrl!,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),

                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: mentor.mentorType == MentorType.online
                            ? Colors.green.withValues(alpha: 0.9)
                            : Colors.orange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            mentor.mentorType == MentorType.online
                                ? Icons.wifi
                                : Icons.location_on,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            mentor.mentorType.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      mentor.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 1), // Reduced from 2 to 1

                    SizedBox(
                      height: 22, // Reduced from 24 to 22 for tighter fit
                      child: Text(
                        mentor.formattedRole,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.brightYellow,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 1.0, // Tight line height
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 5), // Reduced from 6 to 5
                    // Top specializations (single row only for compact view)
                    if (mentor.specializations.isNotEmpty) ...[
                      SizedBox(
                        height: 14, // Reduced height to fit better
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: mentor.topSpecializations
                                .take(3) // Max 3 chips for better fit
                                .map(
                                  (skill) => Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1, // Reduced from 2 to 1
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.rocketRed.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.rocketRed.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 0.5, // Thinner border
                                      ),
                                    ),
                                    child: Text(
                                      skill,
                                      style: const TextStyle(
                                        color: AppColors.rocketRed,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6), // Reduced from 8 to 6
                    ] else ...[
                      const SizedBox(height: 6), // Reduced from 8 to 6
                    ],

                    const Spacer(),

                    // Active hours indicator (always show)
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppColors.brightYellow,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mentor.formattedActiveHours,
                            style: AppTextStyles.bodyTiny.copyWith(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    final initials = mentor.name
        .split(' ')
        .where((name) => name.isNotEmpty)
        .take(2)
        .map((name) => name[0].toUpperCase())
        .join();

    return Container(
      width: double.infinity,
      color: AppColors.deepBlue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.rocketRed.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.rocketRed, width: 2),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.rocketRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mentor.name.split(' ').first,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
