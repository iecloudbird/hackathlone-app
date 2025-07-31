import 'package:supabase_flutter/supabase_flutter.dart';

/// Enhanced QR scanning service with Supabase integration
/// Pure business logic service - NO state management
class QrScanService {
  final SupabaseClient _supabase;

  QrScanService(this._supabase);

  /// Process QR code scan using the enhanced Supabase function
  Future<QrScanResult> processQrScan({
    required String qrCode,
    required String scanType,
    String? eventId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Call the Supabase function
      final response = await _supabase.rpc(
        'process_qr_scan',
        params: {
          'qr_code_text': qrCode,
          'scanner_id': currentUser.id,
          'scan_type_param': scanType,
          'event_id_param': eventId,
        },
      );

      return QrScanResult.fromJson(response);
    } catch (e) {
      final error = 'QR scan failed: ${e.toString()}';
      return QrScanResult.error(error);
    }
  }

  /// Get scan logs for a specific user
  Future<List<QrScanLog>> getUserScanLogs(String userId) async {
    try {
      final response = await _supabase
          .from('qr_scan_logs')
          .select('''
            id, qr_code, scan_type, scan_result, scanned_at, metadata,
            scanned_user:profiles!scanned_user_id(id, full_name, email),
            scanner_admin:profiles!scanner_admin_id(id, full_name),
            event:events(id, name, event_type)
          ''')
          .eq('scanned_user_id', userId)
          .order('scanned_at', ascending: false);

      return response
          .map<QrScanLog>((data) => QrScanLog.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch scan logs: ${e.toString()}');
    }
  }

  /// Get scan logs for a specific event
  Future<List<QrScanLog>> getEventScanLogs(String eventId) async {
    try {
      final response = await _supabase
          .from('qr_scan_logs')
          .select('''
            id, qr_code, scan_type, scan_result, scanned_at, metadata,
            scanned_user:profiles!scanned_user_id(id, full_name, email),
            scanner_admin:profiles!scanner_admin_id(id, full_name),
            event:events(id, name, event_type)
          ''')
          .eq('event_id', eventId)
          .order('scanned_at', ascending: false);

      return response
          .map<QrScanLog>((data) => QrScanLog.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch event scan logs: ${e.toString()}');
    }
  }

  /// Get today's meal scans for a user
  Future<List<QrScanLog>> getTodayMealScans(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('qr_scan_logs')
          .select('''
            id, qr_code, scan_type, scan_result, scanned_at, metadata,
            scanned_user:profiles!scanned_user_id(id, full_name, email),
            scanner_admin:profiles!scanner_admin_id(id, full_name),
            event:events(id, name, event_type)
          ''')
          .eq('scanned_user_id', userId)
          .inFilter('scan_type', ['breakfast', 'lunch', 'dinner'])
          .gte('scanned_at', startOfDay.toIso8601String())
          .lt('scanned_at', endOfDay.toIso8601String())
          .order('scanned_at', ascending: false);

      return response
          .map<QrScanLog>((data) => QrScanLog.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch meal scans: ${e.toString()}');
    }
  }

  /// Check if user has already scanned for specific meal today
  Future<bool> hasMealScanToday(String userId, String mealType) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('qr_scan_logs')
          .select('id')
          .eq('scanned_user_id', userId)
          .eq('scan_type', mealType)
          .eq('scan_result', 'success')
          .gte('scanned_at', startOfDay.toIso8601String())
          .lt('scanned_at', endOfDay.toIso8601String())
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get scan statistics
  Future<QrScanStats> getScanStats() async {
    try {
      final response = await _supabase.rpc('get_scan_statistics');
      return QrScanStats.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch scan statistics: ${e.toString()}');
    }
  }
}

/// Result of a QR scan operation
class QrScanResult {
  final bool success;
  final String? error;
  final String? userId;
  final String? fullName;
  final String? email;
  final String? scanType;
  final DateTime? timestamp;

  const QrScanResult({
    required this.success,
    this.error,
    this.userId,
    this.fullName,
    this.email,
    this.scanType,
    this.timestamp,
  });

  factory QrScanResult.fromJson(Map<String, dynamic> json) {
    return QrScanResult(
      success: json['success'] ?? false,
      error: json['error'],
      userId: json['user_id'],
      fullName: json['full_name'],
      email: json['email'],
      scanType: json['scan_type'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  factory QrScanResult.error(String error) {
    return QrScanResult(success: false, error: error);
  }

  bool get isSuccess => success && error == null;
  bool get isAlreadyScanned =>
      error != null && error!.contains('Already scanned');
  bool get isInvalidCode => error != null && error!.contains('Invalid QR code');
}

/// QR scan log entry
class QrScanLog {
  final String id;
  final String qrCode;
  final String scanType;
  final String scanResult;
  final DateTime scannedAt;
  final Map<String, dynamic>? metadata;
  final UserProfile? scannedUser;
  final UserProfile? scannerAdmin;
  final EventSummary? event;

  const QrScanLog({
    required this.id,
    required this.qrCode,
    required this.scanType,
    required this.scanResult,
    required this.scannedAt,
    this.metadata,
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
}

/// QR scan statistics
class QrScanStats {
  final int totalScans;
  final int todayScans;
  final int breakfastScans;
  final int lunchScans;
  final int dinnerScans;
  final int checkinScans;

  const QrScanStats({
    required this.totalScans,
    required this.todayScans,
    required this.breakfastScans,
    required this.lunchScans,
    required this.dinnerScans,
    required this.checkinScans,
  });

  factory QrScanStats.fromJson(Map<String, dynamic> json) {
    return QrScanStats(
      totalScans: json['total_scans'] ?? 0,
      todayScans: json['today_scans'] ?? 0,
      breakfastScans: json['breakfast_scans'] ?? 0,
      lunchScans: json['lunch_scans'] ?? 0,
      dinnerScans: json['dinner_scans'] ?? 0,
      checkinScans: json['checkin_scans'] ?? 0,
    );
  }

  factory QrScanStats.empty() {
    return const QrScanStats(
      totalScans: 0,
      todayScans: 0,
      breakfastScans: 0,
      lunchScans: 0,
      dinnerScans: 0,
      checkinScans: 0,
    );
  }
}
