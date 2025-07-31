import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event/event.dart';

/// Pure business logic service for event operations
/// Does NOT manage state - only performs API operations
class EventService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all events from the database
  Future<List<Event>> fetchEvents() async {
    final response = await _supabase
        .from('events')
        .select()
        .order('start_time', ascending: true);

    return response.map<Event>((data) {
      return Event(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        type: EventType.fromString(data['type']),
        startTime: DateTime.parse(data['start_time']),
        endTime: data['end_time'] != null
            ? DateTime.parse(data['end_time'])
            : null,
        location: data['location'],
        maxParticipants: data['max_participants'],
        currentParticipants: data['current_participants'] ?? 0,
        isActive: data['is_active'] ?? true,
        requiresQrScan: data['requires_qr_scan'] ?? false,
        qrCodeData: data['qr_code_data'],
        createdAt: DateTime.parse(data['created_at']),
      );
    }).toList();
  }

  /// Get a single event by ID
  Future<Event> getEvent(String eventId) async {
    final response = await _supabase
        .from('events')
        .select()
        .eq('id', eventId)
        .single();

    return Event(
      id: response['id'],
      name: response['name'],
      description: response['description'],
      type: EventType.fromString(response['type']),
      startTime: DateTime.parse(response['start_time']),
      endTime: response['end_time'] != null
          ? DateTime.parse(response['end_time'])
          : null,
      location: response['location'],
      maxParticipants: response['max_participants'],
      currentParticipants: response['current_participants'] ?? 0,
      isActive: response['is_active'] ?? true,
      requiresQrScan: response['requires_qr_scan'] ?? false,
      qrCodeData: response['qr_code_data'],
      createdAt: DateTime.parse(response['created_at']),
    );
  }

  /// Create a new event (admin only)
  Future<Event> createEvent({
    required String name,
    String? description,
    required EventType type,
    required DateTime startTime,
    DateTime? endTime,
    String? location,
    int? maxParticipants,
    bool requiresQrScan = false,
    String? qrCodeData,
  }) async {
    final eventData = {
      'name': name,
      'description': description,
      'type': _eventTypeToString(type),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'location': location,
      'max_participants': maxParticipants,
      'requires_qr_scan': requiresQrScan,
      'qr_code_data': qrCodeData,
    };

    final response = await _supabase
        .from('events')
        .insert(eventData)
        .select()
        .single();

    return Event(
      id: response['id'],
      name: response['name'],
      description: response['description'],
      type: EventType.fromString(response['type']),
      startTime: DateTime.parse(response['start_time']),
      endTime: response['end_time'] != null
          ? DateTime.parse(response['end_time'])
          : null,
      location: response['location'],
      maxParticipants: response['max_participants'],
      currentParticipants: response['current_participants'] ?? 0,
      isActive: response['is_active'] ?? true,
      requiresQrScan: response['requires_qr_scan'] ?? false,
      qrCodeData: response['qr_code_data'],
      createdAt: DateTime.parse(response['created_at']),
    );
  }

  /// Register for an event
  Future<void> registerForEvent(String eventId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('event_participants').insert({
      'event_id': eventId,
      'user_id': user.id,
    });
  }

  /// Unregister from an event
  Future<void> unregisterFromEvent(String eventId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase
        .from('event_participants')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', user.id);
  }

  /// Check if user is registered for an event
  Future<bool> isRegisteredForEvent(String eventId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final response = await _supabase
        .from('event_participants')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', user.id);

    return response.isNotEmpty;
  }

  /// Get user's registered events
  Future<List<Event>> getUserRegisteredEvents() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('event_participants')
        .select('''
          events (
            id, name, description, type, start_time, end_time,
            location, max_participants, current_participants,
            is_active, requires_qr_scan, qr_code_data, created_at
          )
        ''')
        .eq('user_id', user.id);

    return response.map<Event>((data) {
      final eventData = data['events'];
      return Event(
        id: eventData['id'],
        name: eventData['name'],
        description: eventData['description'],
        type: EventType.fromString(eventData['type']),
        startTime: DateTime.parse(eventData['start_time']),
        endTime: eventData['end_time'] != null
            ? DateTime.parse(eventData['end_time'])
            : null,
        location: eventData['location'],
        maxParticipants: eventData['max_participants'],
        currentParticipants: eventData['current_participants'] ?? 0,
        isActive: eventData['is_active'] ?? true,
        requiresQrScan: eventData['requires_qr_scan'] ?? false,
        qrCodeData: eventData['qr_code_data'],
        createdAt: DateTime.parse(eventData['created_at']),
      );
    }).toList();
  }

  String _eventTypeToString(EventType type) {
    switch (type) {
      case EventType.workshop:
        return 'workshop';
      case EventType.networking:
        return 'networking';
      case EventType.presentation:
        return 'presentation';
      case EventType.breakfast:
        return 'breakfast';
      case EventType.lunch:
        return 'lunch';
      case EventType.dinner:
        return 'dinner';
      case EventType.registration:
        return 'registration';
      case EventType.other:
        return 'other';
    }
  }
}
