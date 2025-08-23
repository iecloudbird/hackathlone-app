import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'event.dart';

part 'timeline_event.g.dart';

/// Extended Event model for timeline display with notification preferences
@HiveType(typeId: 9)
class TimelineEvent extends Event {
  @HiveField(13)
  final bool notificationEnabled;

  @HiveField(14)
  final String? notificationId; // For tracking scheduled notifications

  const TimelineEvent({
    required super.id,
    required super.name,
    super.description,
    required super.type,
    required super.startTime,
    super.endTime,
    super.location,
    super.maxParticipants,
    super.currentParticipants = 0,
    super.isActive = true,
    super.requiresQrScan = false,
    super.qrCodeData,
    required super.createdAt,
    this.notificationEnabled = false,
    this.notificationId,
  });

  /// Convert Event to TimelineEvent
  factory TimelineEvent.fromEvent(
    Event event, {
    bool notificationEnabled = false,
    String? notificationId,
  }) {
    return TimelineEvent(
      id: event.id,
      name: event.name,
      description: event.description,
      type: event.type,
      startTime: event.startTime,
      endTime: event.endTime,
      location: event.location,
      maxParticipants: event.maxParticipants,
      currentParticipants: event.currentParticipants,
      isActive: event.isActive,
      requiresQrScan: event.requiresQrScan,
      qrCodeData: event.qrCodeData,
      createdAt: event.createdAt,
      notificationEnabled: notificationEnabled,
      notificationId: notificationId,
    );
  }

  @override
  TimelineEvent copyWith({
    String? id,
    String? name,
    String? description,
    EventType? type,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    int? maxParticipants,
    int? currentParticipants,
    bool? isActive,
    bool? requiresQrScan,
    String? qrCodeData,
    DateTime? createdAt,
    bool? notificationEnabled,
    String? notificationId,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isActive: isActive ?? this.isActive,
      requiresQrScan: requiresQrScan ?? this.requiresQrScan,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      createdAt: createdAt ?? this.createdAt,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'notification_enabled': notificationEnabled,
      'notification_id': notificationId,
    });
    return json;
  }

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    final event = Event.fromJson(json);
    return TimelineEvent(
      id: event.id,
      name: event.name,
      description: event.description,
      type: event.type,
      startTime: event.startTime,
      endTime: event.endTime,
      location: event.location,
      maxParticipants: event.maxParticipants,
      currentParticipants: event.currentParticipants,
      isActive: event.isActive,
      requiresQrScan: event.requiresQrScan,
      qrCodeData: event.qrCodeData,
      createdAt: event.createdAt,
      notificationEnabled: json['notification_enabled'] ?? false,
      notificationId: json['notification_id'],
    );
  }

  /// Get time remaining until event starts
  String get timeLeftText {
    final timeLeft = timeUntilStart;
    if (timeLeft == null || timeLeft.isNegative) return 'Started';

    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes % 60;

    if (hours > 24) {
      final days = timeLeft.inDays;
      return 'Starts in $days day${days > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return 'Starts in $hours hour${hours > 1 ? 's' : ''}';
    } else if (minutes > 0) {
      return 'Starts in $minutes min${minutes > 1 ? 's' : ''}';
    } else {
      return 'Starting now';
    }
  }

  /// Get badge color based on time until start
  Color get badgeColor {
    final timeLeft = timeUntilStart;
    if (timeLeft == null) return Colors.grey;

    // Martian red if within 3 hours, dark orange otherwise
    return timeLeft.inHours <= 3
        ? const Color(0xFFBE1100)
        : const Color(0xFFFF5D00);
  }

  /// Check if this is a timeline/informative event (workshop, presentation, networking, other)
  bool get isTimelineEvent {
    return type == EventType.workshop ||
        type == EventType.presentation ||
        type == EventType.networking ||
        type == EventType.other;
  }

  /// Format date for display (e.g., "16 OCT")
  String get formattedDate {
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
    return '${startTime.day} ${months[startTime.month - 1]}';
  }

  /// Format time for display (e.g., "9:00 A.M.")
  String get formattedTime {
    final hour = startTime.hour == 0
        ? 12
        : (startTime.hour > 12 ? startTime.hour - 12 : startTime.hour);
    final minute = startTime.minute.toString().padLeft(2, '0');
    final period = startTime.hour >= 12 ? 'P.M.' : 'A.M.';
    return '$hour:$minute $period';
  }
}
