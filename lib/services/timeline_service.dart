import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event/timeline_event.dart';
import '../models/event/event.dart';

/// Service for timeline event operations - extends EventService functionality
class TimelineService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch events suitable for timeline display (workshops, presentations, networking, other)
  Future<List<TimelineEvent>> fetchTimelineEvents() async {
    print('🌐 TimelineService: Fetching timeline events');

    final response = await _supabase
        .from('events')
        .select()
        .inFilter('event_type', [
          'workshop',
          'presentation',
          'networking',
          'other',
        ])
        .eq('is_active', true)
        .order('start_time', ascending: true);

    print('📊 TimelineService: Received ${response.length} events');

    return response.map<TimelineEvent>((data) {
      final event = Event.fromJson(_transformDatabaseResponse(data));
      return TimelineEvent.fromEvent(event);
    }).toList();
  }

  /// Fetch upcoming timeline events (next 2 for home screen)
  Future<List<TimelineEvent>> fetchUpcomingTimelineEvents({
    int limit = 2,
  }) async {
    print('🔄 TimelineService: Fetching $limit upcoming timeline events');

    final now = DateTime.now().toUtc();
    final response = await _supabase
        .from('events')
        .select()
        .inFilter('event_type', [
          'workshop',
          'presentation',
          'networking',
          'other',
        ])
        .eq('is_active', true)
        .gt('start_time', now.toIso8601String())
        .order('start_time', ascending: true)
        .limit(limit);

    print('📊 TimelineService: Received ${response.length} upcoming events');

    return response.map<TimelineEvent>((data) {
      final event = Event.fromJson(_transformDatabaseResponse(data));
      return TimelineEvent.fromEvent(event);
    }).toList();
  }

  /// Fetch events by date range for the events screen tabs
  Future<List<TimelineEvent>> fetchEventsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    print('📅 TimelineService: Fetching events from $startDate to $endDate');

    final response = await _supabase
        .from('events')
        .select()
        .inFilter('event_type', [
          'workshop',
          'presentation',
          'networking',
          'other',
        ])
        .eq('is_active', true)
        .gte('start_time', startDate.toUtc().toIso8601String())
        .lte('start_time', endDate.toUtc().toIso8601String())
        .order('start_time', ascending: true);

    print(
      '📊 TimelineService: Received ${response.length} events for date range',
    );

    return response.map<TimelineEvent>((data) {
      final event = Event.fromJson(_transformDatabaseResponse(data));
      return TimelineEvent.fromEvent(event);
    }).toList();
  }

  /// Toggle notification for a timeline event
  Future<void> toggleEventNotification(String eventId, bool enabled) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    print(
      '🔔 TimelineService: Toggling notification for event $eventId: $enabled',
    );

    try {
      if (enabled) {
        // Create or update notification preference
        await _supabase.from('event_notifications').upsert({
          'user_id': user.id,
          'event_id': eventId,
          'enabled': true,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
        print('✅ TimelineService: Notification enabled for event $eventId');
      } else {
        // Delete notification preference
        await _supabase
            .from('event_notifications')
            .delete()
            .eq('user_id', user.id)
            .eq('event_id', eventId);
        print('❌ TimelineService: Notification disabled for event $eventId');
      }
    } catch (e) {
      print('💥 TimelineService: Failed to toggle notification: $e');
      throw Exception('Failed to update notification preference: $e');
    }
  }

  /// Get user's notification preferences for events
  Future<Map<String, bool>> getUserNotificationPreferences() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print(
        '⚠️ TimelineService: No authenticated user for notification preferences',
      );
      return {};
    }

    try {
      final response = await _supabase
          .from('event_notifications')
          .select('event_id, enabled')
          .eq('user_id', user.id);

      final preferences = <String, bool>{};
      for (final row in response) {
        preferences[row['event_id']] = row['enabled'] ?? false;
      }

      print(
        '📱 TimelineService: Retrieved ${preferences.length} notification preferences',
      );
      return preferences;
    } catch (e) {
      print('💥 TimelineService: Failed to get notification preferences: $e');
      return {};
    }
  }

  /// Transform database response to match Event.fromJson expectations
  Map<String, dynamic> _transformDatabaseResponse(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'name': data['name'],
      'description': data['description'],
      'type':
          data['event_type'], // Database uses 'event_type', model expects 'type'
      'start_time': data['start_time'],
      'end_time': data['end_time'],
      'location': data['location'],
      'max_participants': data['max_participants'],
      'current_participants': data['current_participants'] ?? 0,
      'is_active': data['is_active'] ?? true,
      'requires_qr_scan':
          data['requires_qr'] ?? false, // Database uses 'requires_qr'
      'qr_code_data': data['qr_code_data'],
      'created_at': data['created_at'],
    };
  }
}
