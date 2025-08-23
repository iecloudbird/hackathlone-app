import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/timeline_provider.dart';
import '../../../router/app_routes.dart';
import '../../../core/theme.dart';
import '../../../common/widgets/timeline_event_card.dart';

class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUpcomingEventsSection(context),
          // Hide for now, not sure what the best use case is
          // const SizedBox(height: 24),
          // _buildEventsTimelineSection(context),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Events',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Overpass',
          ),
        ),
        const SizedBox(height: 16),
        Consumer<TimelineProvider>(
          builder: (context, timelineProvider, child) {
            if (timelineProvider.isLoading) {
              return _buildLoadingState();
            }

            if (timelineProvider.errorMessage != null) {
              return _buildErrorState(timelineProvider.errorMessage!);
            }

            final upcomingEvents = timelineProvider.upcomingEventsForHome;

            if (upcomingEvents.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: upcomingEvents.map((event) {
                return TimelineEventCard(
                  event: event,
                  showDate: true,
                  showTime: false,
                  showTimeLeft: true,
                  isExpandable: false,
                  onTap: () => context.go(AppRoutes.events),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Widget _buildEventsTimelineSection(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Events Timeline',
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 18,
  //           fontWeight: FontWeight.w600,
  //           fontFamily: 'Overpass',
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       Consumer<TimelineProvider>(
  //         builder: (context, timelineProvider, child) {
  //           final allEvents = timelineProvider.upcomingEvents.take(5).toList();

  //           if (allEvents.isEmpty) {
  //             return const SizedBox();
  //           }

  //           return Column(
  //             children: allEvents.map((event) {
  //               return TimelineEventCard(
  //                 event: event,
  //                 showDate: true,
  //                 showTime:
  //                     false, // Don't show time for home screen (already in date column)
  //                 showTimeLeft: true,
  //                 isExpandable: false,
  //                 onTap: () => context.go(AppRoutes.events),
  //               );
  //             }).toList(),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildLoadingState() {
    return Container(
      height: 120,
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.brightYellow,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading events...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Overpass',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.rocketRed, size: 24),
            const SizedBox(height: 8),
            Text(
              'Failed to load events',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontFamily: 'Overpass',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontFamily: 'Overpass',
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              color: Colors.white.withValues(alpha: 0.5),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'No upcoming events',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Overpass',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later for new events',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontFamily: 'Overpass',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
