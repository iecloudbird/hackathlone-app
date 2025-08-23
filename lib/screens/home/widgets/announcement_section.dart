import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';

/// Announcement section with NASA Space Apps and HackAthlone information
class AnnouncementSection extends StatelessWidget {
  const AnnouncementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                double screenWidth = MediaQuery.of(context).size.width;
                double cardWidth = screenWidth * 0.85;

                Widget card;
                switch (index) {
                  case 0:
                    card = _buildSpaceAppsCard();
                  case 1:
                    card = _buildHackAthloneCard();
                  case 2:
                    card = _buildTeamFormationCard();
                  default:
                    card = Container();
                }

                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 8.0, // No left margin for first card
                    right: index == 2
                        ? 16.0
                        : 8.0, // Extra right margin for last card
                  ),
                  child: card,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceAppsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E), // Dark blue
            Color(0xFF16213E), // Darker blue
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern (placeholder for image)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.spiroDiscoBall.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.rocket_launch_outlined,
                  color: AppColors.spiroDiscoBall,
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  'NASA Space Apps Challenge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Overpass',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join the world\'s largest global hackathon to solve challenges using NASA\'s open data.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontFamily: 'Overpass',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () =>
                      _launchURL('https://www.spaceappschallenge.org/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spiroDiscoBall,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Learn More',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Overpass',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHackAthloneCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A1810), // Dark orange/brown
            Color(0xFF3D1A00), // Darker orange/brown
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern (placeholder for HackAthlone logo)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C00).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'HA',
                    style: TextStyle(
                      color: Color(0xFFFF8C00),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Overpass',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'What is HackAthlone?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Overpass',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn about our team and mission to create innovative solutions for global challenges.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontFamily: 'Overpass',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () =>
                      _launchURL('https://www.hackathlone.com/about'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Overpass',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamFormationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D4F3C), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.groups_outlined,
                  color: Colors.green,
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Form Your Team!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Overpass',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Registration is open! Don\'t have a team? Connect with other participants and form one.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontFamily: 'Overpass',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    _launchURL(
                      'https://www.spaceappschallenge.org/2025/local-events/athlone/',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Register Now',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Overpass',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // fallback to platform default
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e2) {
        try {
          await launchUrl(uri);
        } catch (e3) {
          // silent fail
        }
      }
    }
  }
}
