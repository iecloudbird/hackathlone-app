import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timeline_provider.dart';
import '../../core/theme.dart';
import '../../common/widgets/timeline_event_card.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<dynamic>> _eventsByDate = {}; // Store events by date

  @override
  void initState() {
    super.initState();

    // Create tabs for 3 days: Oct 3rd 6pm to Oct 5th
    final eventDates = _getEventDates();
    _tabController = TabController(length: eventDates.length, vsync: this);

    // Load timeline events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventsForAllDays();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Get the dates for the hackathon event (Oct 3-5, 2025)
  List<DateTime> _getEventDates() {
    return [
      DateTime(2025, 10, 3), // Oct 3rd
      DateTime(2025, 10, 4), // Oct 4th
      DateTime(2025, 10, 5), // Oct 5th
    ];
  }

  /// Load events for all days
  Future<void> _loadEventsForAllDays() async {
    final timelineProvider = context.read<TimelineProvider>();
    await timelineProvider.fetchTimelineEvents();

    // Group events by date
    _eventsByDate.clear();
    for (final date in _getEventDates()) {
      final events = await timelineProvider.fetchEventsByDate(date);
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      _eventsByDate[dateKey] = events;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventDates = _getEventDates();

    return Scaffold(
      backgroundColor: const Color(0xFF000613), // Same as home screen
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Event Timeline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Overpass',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDateTabs(eventDates),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: eventDates
                    .map((date) => _buildEventsForDate(date))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTabs(List<DateTime> dates) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.maastrichtBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.brightYellow,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Overpass',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Overpass',
        ),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: dates.map((date) {
          final months = [
            'JAN',
            'FEB',
            'MAR',
            'APR',
            'MAY',
            'JUN',
            'JUL',
            'AUG',
            'SEP',
            'OCT',
            'NOV',
            'DEC',
          ];
          final formattedDate = '${date.day} ${months[date.month - 1]}';

          return Tab(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(formattedDate),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventsForDate(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final events = _eventsByDate[dateKey] ?? [];

    return Container(
      color: const Color(0xFF000613), // Same as home screen
      child: Consumer<TimelineProvider>(
        builder: (context, timelineProvider, child) {
          if (timelineProvider.isLoading && events.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.spiroDiscoBall),
            );
          }

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events scheduled',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontFamily: 'Overpass',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadEventsForAllDays,
            color: AppColors.spiroDiscoBall,
            backgroundColor: const Color(0xFF000613), // Same as home screen
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return TimelineEventCard(
                  event: event,
                  showDate: false, // Don't show date since it's in the tab
                  showTimeLeft: false, // Don't show time left in events screen
                  isExpandable: true, // Make it expandable
                  showTime: true, // Show time in events screen
                  onTap: () {
                    // The card will handle its own expansion state
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
