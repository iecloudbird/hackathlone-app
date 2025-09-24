import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/constants/constants.dart';
import '../../../models/mentor/mentor.dart';
import '../../../providers/mentor_provider.dart';
import 'compact_mentor_card.dart';

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
          // Section header with mentor counts
          Consumer<MentorProvider>(
            builder: (context, mentorProvider, child) {
              final ongroundCount = mentorProvider.mentors
                  .where((m) => m.mentorType == MentorType.onground)
                  .length;
              final onlineCount = mentorProvider.mentors
                  .where((m) => m.mentorType == MentorType.online)
                  .length;

              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meet Our Mentors',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Overpass',
                          ),
                        ),
                        if (mentorProvider.mentors.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildCountChip(
                                ongroundCount,
                                MentorType.onground,
                              ),
                              const SizedBox(width: 8),
                              _buildCountChip(onlineCount, MentorType.online),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Mentors grid
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
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Colors.white30,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No mentors available',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check back soon for mentor updates',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Grid layout for mentors
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75, // Slightly taller cards
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: mentorProvider.mentors.length,
                  itemBuilder: (context, index) {
                    final mentor = mentorProvider.mentors[index];
                    return CompactMentorCard(mentor: mentor);
                  },
                );
              }
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCountChip(int count, MentorType type) {
    final color = type == MentorType.online ? Colors.green : Colors.orange;
    final icon = type == MentorType.online ? Icons.wifi : Icons.location_on;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count ${type.displayName.toLowerCase()}',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
