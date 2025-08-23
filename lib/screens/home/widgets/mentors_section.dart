import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../models/mentor/mentor.dart';
import '../../../services/mentor_service.dart';

class MentorsSection extends StatefulWidget {
  const MentorsSection({super.key});

  @override
  State<MentorsSection> createState() => _MentorsSectionState();
}

class _MentorsSectionState extends State<MentorsSection> {
  final MentorService _mentorService = MentorService();
  List<Mentor> mentors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
    try {
      final fetchedMentors = await _mentorService.fetchMentors();
      if (mounted) {
        setState(() {
          mentors = fetchedMentors;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading mentors: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          // Use mock data for demo
          mentors = _getMockMentors();
        });
      }
    }
  }

  // Mock data for development/demo
  List<Mentor> _getMockMentors() {
    return [
      Mentor(
        id: '1',
        name: 'Michael Chen',
        role: 'AI/ML Engineer',
        company: 'OpenAI',
        description:
            'Machine learning researcher focused on practical AI applications in mobile and web development.',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
      ),
      Mentor(
        id: '2',
        name: 'Emily Rodriguez',
        role: 'Product Manager',
        company: 'Meta',
        description:
            'Product strategy expert helping teams build user-centered solutions that scale globally.',
        imageUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
      ),
      Mentor(
        id: '3',
        name: 'Alex Kumar',
        role: 'DevOps Engineer',
        company: 'AWS',
        description:
            'Cloud infrastructure specialist with expertise in scalable systems and CI/CD pipelines.',
        imageUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
      ),
      Mentor(
        id: '4',
        name: 'Jessica Wong',
        role: 'UX Designer',
        company: 'Spotify',
        description:
            'User experience designer focused on creating intuitive and accessible digital experiences.',
        imageUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&crop=face',
      ),
    ];
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
          if (isLoading)
            Center(
              child: Padding(
                padding: AppDimensions.paddingAll32,
                child: CircularProgressIndicator(color: AppColors.rocketRed),
              ),
            )
          else if (mentors.isEmpty)
            Center(
              child: Padding(
                padding: AppDimensions.paddingAll32,
                child: Text(
                  'No mentors available at the moment',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 350, // Increased height to accommodate content properly
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mentors.length,
                itemBuilder: (context, index) {
                  final mentor = mentors[index];
                  // Calculate card width to show partial next card
                  double screenWidth = MediaQuery.of(context).size.width;
                  double cardWidth = screenWidth * 0.75; // 75% of screen width

                  return Container(
                    width: cardWidth,
                    margin: EdgeInsets.only(
                      left: index == 0
                          ? 0
                          : 8.0, // No left margin for first card
                      right: index == mentors.length - 1
                          ? 16.0
                          : 8.0, // Extra right margin for last card
                    ),
                    child: _MentorCard(mentor: mentor),
                  );
                },
              ),
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
                        alignment: Alignment.topCenter, // Always start from top
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

                  const SizedBox(height: 8),

                  // Role and company
                  Text(
                    mentor.formattedRole,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.rocketRed,
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
