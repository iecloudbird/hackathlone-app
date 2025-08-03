/// Scan event model for event selection in QR scanning
class ScanEvent {
  final String id;
  final String name;
  final String eventType;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final bool requiresQr;

  const ScanEvent({
    required this.id,
    required this.name,
    required this.eventType,
    required this.startTime,
    this.endTime,
    this.location,
    required this.requiresQr,
  });

  factory ScanEvent.fromJson(Map<String, dynamic> json) {
    print('🔧 ScanEvent.fromJson: Input data: $json');

    try {
      final event = ScanEvent(
        id: json['id'] as String,
        name: json['name'] as String,
        eventType: json['event_type'] as String,
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: json['end_time'] != null
            ? DateTime.parse(json['end_time'] as String)
            : null,
        location: json['location'] as String?,
        requiresQr: json['requires_qr'] as bool,
      );

      print(
        '✅ ScanEvent.fromJson: Successfully created event ${event.id} - ${event.name}',
      );
      return event;
    } catch (e) {
      print('❌ ScanEvent.fromJson: Error creating event: $e');
      print('🔍 ScanEvent.fromJson: Error type: ${e.runtimeType}');
      print('📋 ScanEvent.fromJson: JSON keys: ${json.keys.toList()}');
      print('📋 ScanEvent.fromJson: JSON values: ${json.values.toList()}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'event_type': eventType,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'location': location,
      'requires_qr': requiresQr,
    };
  }
}
