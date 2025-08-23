import 'package:flutter/material.dart';
import '../services/timeline_service.dart';
import '../models/event/timeline_event.dart';
import '../utils/storage.dart';

/// Provider for timeline events with state management and notification preferences
class TimelineProvider with ChangeNotifier {
  final TimelineService _timelineService;

  List<TimelineEvent> _timelineEvents = [];
  Map<String, List<TimelineEvent>> _eventsByDate = {}; // Cache events by date
  Map<String, bool> _notificationPreferences = {};
  bool _isLoading = false;
  String? _errorMessage;

  TimelineProvider({TimelineService? timelineService})
    : _timelineService = timelineService ?? TimelineService();

  // Getters
  List<TimelineEvent> get timelineEvents => _timelineEvents;
  List<TimelineEvent> get upcomingEvents {
    final now = DateTime.now();
    return _timelineEvents.where((e) => e.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<TimelineEvent> get upcomingEventsForHome {
    return upcomingEvents.take(2).toList();
  }

  Map<String, bool> get notificationPreferences => _notificationPreferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if notifications are enabled for a specific event
  bool isNotificationEnabled(String eventId) {
    return _notificationPreferences[eventId] ?? false;
  }

  /// Fetch all timeline events
  Future<void> fetchTimelineEvents() async {
    print('🔄 TimelineProvider: Starting to fetch timeline events');
    _setLoading(true);
    _clearError();

    try {
      // Check cache staleness first
      final isCacheStale = await _isCachedTimelineStale();
      print('🔍 TimelineProvider: Cache stale check result: $isCacheStale');

      List<TimelineEvent> events;

      if (isCacheStale) {
        // Cache is stale, fetch fresh from database
        print(
          '🌐 TimelineProvider: Fetching fresh timeline events from database',
        );
        events = await _timelineService.fetchTimelineEvents();

        // Cache the fresh events
        await _cacheTimelineEvents(events);
        print('💾 TimelineProvider: Cached ${events.length} timeline events');
      } else {
        // Cache is current, use cached events
        print('📱 TimelineProvider: Using cached timeline events');
        events = _getCachedTimelineEvents();
      }

      // Load notification preferences if user is authenticated
      await _loadNotificationPreferences();

      // Apply notification preferences to events
      _timelineEvents = events.map((event) {
        final notificationEnabled = isNotificationEnabled(event.id);
        return event.copyWith(notificationEnabled: notificationEnabled);
      }).toList();

      print(
        '✅ TimelineProvider: Loaded ${_timelineEvents.length} timeline events',
      );
      notifyListeners();
    } catch (e) {
      print('❌ TimelineProvider: Error fetching timeline events: $e');
      _setError('Failed to load timeline events: ${e.toString()}');

      // Fallback to cache
      try {
        _timelineEvents = _getCachedTimelineEvents();
        print('🔄 TimelineProvider: Using cached events as fallback');
        notifyListeners();
      } catch (cacheError) {
        print('💥 TimelineProvider: Cache fallback also failed: $cacheError');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch upcoming timeline events (for home screen)
  Future<void> fetchUpcomingEvents({int limit = 2}) async {
    print(
      '🏠 TimelineProvider: Fetching $limit upcoming events for home screen',
    );
    _setLoading(true);
    _clearError();

    try {
      final events = await _timelineService.fetchUpcomingTimelineEvents(
        limit: limit,
      );

      // Load notification preferences
      await _loadNotificationPreferences();

      // Apply notification preferences
      _timelineEvents = events.map((event) {
        final notificationEnabled = isNotificationEnabled(event.id);
        return event.copyWith(notificationEnabled: notificationEnabled);
      }).toList();

      print(
        '✅ TimelineProvider: Loaded ${_timelineEvents.length} upcoming events',
      );
      notifyListeners();
    } catch (e) {
      print('❌ TimelineProvider: Error fetching upcoming events: $e');
      _setError('Failed to load upcoming events: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch events by date range (for events screen tabs) - now with caching
  Future<List<TimelineEvent>> fetchEventsByDate(DateTime date) async {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    print('📅 TimelineProvider: Fetching events for date: $date');

    // Check if we already have cached events for this date
    if (_eventsByDate.containsKey(dateKey) &&
        _eventsByDate[dateKey]!.isNotEmpty) {
      print('💾 TimelineProvider: Using cached events for $dateKey');
      return _eventsByDate[dateKey]!;
    }

    // Only set loading state when actually making API call
    _setLoading(true);

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final events = await _timelineService.fetchEventsByDateRange(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      // Apply notification preferences
      final eventsWithNotifications = events.map((event) {
        final notificationEnabled = isNotificationEnabled(event.id);
        return event.copyWith(notificationEnabled: notificationEnabled);
      }).toList();

      // Cache the events for this date
      _eventsByDate[dateKey] = eventsWithNotifications;

      print(
        '✅ TimelineProvider: Loaded and cached ${eventsWithNotifications.length} events for $date',
      );
      return eventsWithNotifications;
    } catch (e) {
      print('❌ TimelineProvider: Error fetching events by date: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle notification for a timeline event
  Future<void> toggleEventNotification(String eventId, bool enabled) async {
    print('🔔 TimelineProvider: Toggling notification for $eventId: $enabled');

    try {
      await _timelineService.toggleEventNotification(eventId, enabled);

      // Update local state
      _notificationPreferences[eventId] = enabled;

      // Update the event in the list
      _timelineEvents = _timelineEvents.map((event) {
        if (event.id == eventId) {
          return event.copyWith(notificationEnabled: enabled);
        }
        return event;
      }).toList();

      print('✅ TimelineProvider: Notification toggled successfully');
      notifyListeners();
    } catch (e) {
      print('❌ TimelineProvider: Failed to toggle notification: $e');
      _setError('Failed to update notification preference: ${e.toString()}');
    }
  }

  /// Load user notification preferences
  Future<void> _loadNotificationPreferences() async {
    try {
      _notificationPreferences = await _timelineService
          .getUserNotificationPreferences();
      print(
        '📱 TimelineProvider: Loaded ${_notificationPreferences.length} notification preferences',
      );
    } catch (e) {
      print('⚠️ TimelineProvider: Failed to load notification preferences: $e');
      _notificationPreferences = {};
    }
  }

  /// Check if cached timeline events are stale
  Future<bool> _isCachedTimelineStale() async {
    try {
      final lastFetch =
          HackCache.localCache.get('timeline_events_last_fetch') as DateTime?;
      if (lastFetch == null) return true;

      // Consider cache stale after 30 minutes
      final staleDuration = const Duration(minutes: 30);
      return DateTime.now().difference(lastFetch) > staleDuration;
    } catch (e) {
      print('⚠️ TimelineProvider: Cache staleness check failed: $e');
      return true;
    }
  }

  /// Cache timeline events
  Future<void> _cacheTimelineEvents(List<TimelineEvent> events) async {
    try {
      final eventsJson = events.map((e) => e.toJson()).toList();
      await HackCache.localCache.put('timeline_events', eventsJson);
      await HackCache.localCache.put(
        'timeline_events_last_fetch',
        DateTime.now(),
      );
      print('💾 TimelineProvider: Cached ${events.length} events');
    } catch (e) {
      print('⚠️ TimelineProvider: Failed to cache events: $e');
    }
  }

  /// Get cached timeline events
  List<TimelineEvent> _getCachedTimelineEvents() {
    try {
      final eventsJson = HackCache.localCache.get('timeline_events') as List?;
      if (eventsJson == null) return [];

      return eventsJson.map<TimelineEvent>((json) {
        return TimelineEvent.fromJson(Map<String, dynamic>.from(json));
      }).toList();
    } catch (e) {
      print('⚠️ TimelineProvider: Failed to get cached events: $e');
      return [];
    }
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _timelineEvents = [];
    _eventsByDate = {};
    _notificationPreferences = {};
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
