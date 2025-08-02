/// Scan event model for event selection in QR scanning
class ScanEvent {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;
  final bool? isActive;

  const ScanEvent({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.isActive,
  });

  factory ScanEvent.fromJson(Map<String, dynamic> json) {
    return ScanEvent(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
