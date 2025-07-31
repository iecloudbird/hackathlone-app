import 'package:flutter/material.dart';
import 'package:hackathlone_app/services/event_service.dart';
import 'package:hackathlone_app/models/event/event.dart';

/// Provider for event operations with state management
class EventProvider with ChangeNotifier {
  final EventService _eventService;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _lastError;

  EventProvider({EventService? eventService})
    : _eventService = eventService ?? EventService();

  // Getters
  List<Event> get events => _events;
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((e) => e.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Event> get todayEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _events
        .where(
          (e) => e.startTime.isAfter(today) && e.startTime.isBefore(tomorrow),
        )
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  /// Fetch all events
  Future<void> fetchEvents() async {
    _setLoading(true);
    _clearError();

    try {
      _events = await _eventService.fetchEvents();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch events: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get a single event by ID
  Future<Event?> getEvent(String eventId) async {
    try {
      return await _eventService.getEvent(eventId);
    } catch (e) {
      _setError('Failed to fetch event: ${e.toString()}');
      return null;
    }
  }

  /// Create a new event (admin only)
  Future<Event?> createEvent({
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
    try {
      final event = await _eventService.createEvent(
        name: name,
        description: description,
        type: type,
        startTime: startTime,
        endTime: endTime,
        location: location,
        maxParticipants: maxParticipants,
        requiresQrScan: requiresQrScan,
        qrCodeData: qrCodeData,
      );

      // Add to local events and sort
      _events.add(event);
      _events.sort((a, b) => a.startTime.compareTo(b.startTime));
      notifyListeners();

      return event;
    } catch (e) {
      _setError('Failed to create event: ${e.toString()}');
      return null;
    }
  }

  /// Register for an event
  Future<bool> registerForEvent(String eventId) async {
    try {
      await _eventService.registerForEvent(eventId);

      // Update local participant count
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        _events[eventIndex] = _events[eventIndex].copyWith(
          currentParticipants: _events[eventIndex].currentParticipants + 1,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to register for event: ${e.toString()}');
      return false;
    }
  }

  /// Unregister from an event
  Future<bool> unregisterFromEvent(String eventId) async {
    try {
      await _eventService.unregisterFromEvent(eventId);

      // Update local participant count
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        _events[eventIndex] = _events[eventIndex].copyWith(
          currentParticipants: _events[eventIndex].currentParticipants - 1,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to unregister from event: ${e.toString()}');
      return false;
    }
  }

  /// Check if user is registered for an event
  Future<bool> isRegisteredForEvent(String eventId) async {
    try {
      return await _eventService.isRegisteredForEvent(eventId);
    } catch (e) {
      return false;
    }
  }

  /// Get user's registered events
  Future<List<Event>> getUserRegisteredEvents() async {
    try {
      return await _eventService.getUserRegisteredEvents();
    } catch (e) {
      _setError('Failed to fetch user events: ${e.toString()}');
      return [];
    }
  }

  /// Get events by type
  List<Event> getEventsByType(EventType type) {
    return _events.where((e) => e.type == type).toList();
  }

  /// Get meal events (breakfast, lunch, dinner)
  List<Event> getMealEvents() {
    return _events
        .where(
          (e) =>
              e.type == EventType.breakfast ||
              e.type == EventType.lunch ||
              e.type == EventType.dinner,
        )
        .toList();
  }

  /// Clear error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _events = [];
    _isLoading = false;
    _lastError = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  void _clearError() {
    _lastError = null;
  }
}
