import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 3)
class Event {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final EventType type;

  @HiveField(4)
  final DateTime startTime;

  @HiveField(5)
  final DateTime? endTime;

  @HiveField(6)
  final String? location;

  @HiveField(7)
  final int? maxParticipants;

  @HiveField(8)
  final int currentParticipants;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final bool requiresQrScan;

  @HiveField(11)
  final String? qrCodeData;

  @HiveField(12)
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.startTime,
    this.endTime,
    this.location,
    this.maxParticipants,
    this.currentParticipants = 0,
    this.isActive = true,
    this.requiresQrScan = false,
    this.qrCodeData,
    required this.createdAt,
  });

  // JSON serialization without json_annotation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'location': location,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'is_active': isActive,
      'requires_qr_scan': requiresQrScan,
      'qr_code_data': qrCodeData,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: EventType.fromString(json['type']),
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      location: json['location'],
      maxParticipants: json['max_participants'],
      currentParticipants: json['current_participants'] ?? 0,
      isActive: json['is_active'] ?? true,
      requiresQrScan: json['requires_qr_scan'] ?? false,
      qrCodeData: json['qr_code_data'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Event copyWith({
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
  }) {
    return Event(
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
    );
  }

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing => endTime != null
      ? DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime!)
      : false;
  bool get isPast =>
      endTime != null ? endTime!.isBefore(DateTime.now()) : false;

  Duration? get duration => endTime?.difference(startTime);
  Duration? get timeUntilStart =>
      isUpcoming ? startTime.difference(DateTime.now()) : null;

  bool get isFull =>
      maxParticipants != null && currentParticipants >= maxParticipants!;
  bool get canRegister => isActive && !isFull && isUpcoming;
}

@HiveType(typeId: 4)
enum EventType {
  @HiveField(0)
  registration,

  @HiveField(1)
  breakfast,

  @HiveField(2)
  lunch,

  @HiveField(3)
  dinner,

  @HiveField(4)
  workshop,

  @HiveField(5)
  presentation,

  @HiveField(6)
  networking,

  @HiveField(7)
  other;

  String get displayName {
    switch (this) {
      case EventType.registration:
        return 'Registration';
      case EventType.breakfast:
        return 'Breakfast';
      case EventType.lunch:
        return 'Lunch';
      case EventType.dinner:
        return 'Dinner';
      case EventType.workshop:
        return 'Workshop';
      case EventType.presentation:
        return 'Presentation';
      case EventType.networking:
        return 'Networking';
      case EventType.other:
        return 'Other';
    }
  }

  static EventType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'registration':
        return EventType.registration;
      case 'breakfast':
        return EventType.breakfast;
      case 'lunch':
        return EventType.lunch;
      case 'dinner':
        return EventType.dinner;
      case 'workshop':
        return EventType.workshop;
      case 'presentation':
        return EventType.presentation;
      case 'networking':
        return EventType.networking;
      default:
        return EventType.other;
    }
  }
}
