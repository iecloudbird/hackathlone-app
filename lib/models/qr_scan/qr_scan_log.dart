/// QR scan log model for tracking scan history
class QrScanLog {
  final String id;
  final String qrCode;
  final String scanType;
  final String scanResult;
  final DateTime scannedAt;
  final Map<String, dynamic>? metadata;
  final String scannedUserId;
  final String scannerId;
  final String? eventId;
  final UserProfile? scannedUser;
  final UserProfile? scannerAdmin;
  final EventSummary? event;

  const QrScanLog({
    required this.id,
    required this.qrCode,
    required this.scanType,
    required this.scanResult,
    required this.scannedAt,
    required this.scannedUserId,
    required this.scannerId,
    this.metadata,
    this.eventId,
    this.scannedUser,
    this.scannerAdmin,
    this.event,
  });

  factory QrScanLog.fromJson(Map<String, dynamic> json) {
    return QrScanLog(
      id: json['id'],
      qrCode: json['qr_code'],
      scanType: json['scan_type'],
      scanResult: json['scan_result'],
      scannedAt: DateTime.parse(json['scanned_at']),
      scannedUserId: json['scanned_user_id'],
      scannerId: json['scanner_id'],
      eventId: json['event_id'],
      metadata: json['metadata'],
      scannedUser: json['scanned_user'] != null
          ? UserProfile.fromJson(json['scanned_user'])
          : null,
      scannerAdmin: json['scanner_admin'] != null
          ? UserProfile.fromJson(json['scanner_admin'])
          : null,
      event: json['event'] != null
          ? EventSummary.fromJson(json['event'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qr_code': qrCode,
      'scan_type': scanType,
      'scan_result': scanResult,
      'scanned_at': scannedAt.toIso8601String(),
      'scanned_user_id': scannedUserId,
      'scanner_id': scannerId,
      'event_id': eventId,
      'metadata': metadata,
    };
  }

  bool get isSuccess => scanResult == 'success';
  bool get isAlreadyUsed => scanResult == 'already_used';
  bool get isInvalid => scanResult == 'invalid';
}

/// User profile summary for scan logs
class UserProfile {
  final String id;
  final String fullName;
  final String? email;

  const UserProfile({required this.id, required this.fullName, this.email});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'email': email};
  }
}

/// Event summary for scan logs
class EventSummary {
  final String id;
  final String name;
  final String eventType;

  const EventSummary({
    required this.id,
    required this.name,
    required this.eventType,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id'],
      name: json['name'],
      eventType: json['event_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'event_type': eventType};
  }
}
