import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../models/mentor/mentor.dart';
import '../../../providers/mentor_provider.dart';

class MentorsSection extends StatefulWidget {
  const MentorsSection({super.key});

  @override
  State<MentorsSection> createState() => _MentorsSectionState();
}

class _MentorsSectionState extends State<MentorsSection> {
  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
    // Load mentors through provider
    final mentorProvider = context.read<MentorProvider>();
    await mentorProvider.fetchMentors();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            'Meet Our Mentors',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Overpass',
            ),
          ),
          const SizedBox(height: 16),

          // Mentor cards carousel
          Consumer<MentorProvider>(
            builder: (context, mentorProvider, child) {
              if (mentorProvider.isLoading) {
                return Center(
                  child: Padding(
                    padding: AppDimensions.paddingAll32,
                    child: CircularProgressIndicator(
                      color: AppColors.brightYellow,
                    ),
                  ),
                );
              } else if (mentorProvider.mentors.isEmpty) {
                return Center(
                  child: Padding(
                    padding: AppDimensions.paddingAll32,
                    child: Text(
                      'No mentors available at the moment',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mentorProvider.mentors.length,
                    itemBuilder: (context, index) {
                      final mentor = mentorProvider.mentors[index];
                      double screenWidth = MediaQuery.of(context).size.width;
                      double cardWidth = screenWidth * 0.75;

                      return Container(
                        width: cardWidth,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 0 : 8.0,
                          right: index == mentorProvider.mentors.length - 1
                              ? 16.0
                              : 8.0,
                        ),
                        child: _MentorCard(mentor: mentor),
                      );
                    },
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  final Mentor mentor;

  const _MentorCard({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.maastrichtBlue,
        borderRadius: AppDimensions.radiusMedium,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Container(
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
          ),

          // Text content below the image - 50% height
          Expanded(
            flex: 5, // Takes 50% of available height
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Mentor name
                  Text(
                    mentor.name,
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    mentor.formattedRole,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.brightYellow,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Expanded(
                    child: Text(
                      mentor.description,
                      style: AppTextStyles.bodyTiny.copyWith(
                        color: Colors.white70,
                        height: 1.4,
                        fontSize: 14,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    // Create placeholder with mentor initials
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.rocketRed.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.rocketRed, width: 2),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.rocketRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                mentor.name,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white70,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
