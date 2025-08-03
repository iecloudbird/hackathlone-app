import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/qr_scan/qr_scan.dart';

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

  /// Get active events for scanning
  Future<List<ScanEvent>> getActiveEvents() async {
    try {
      print('🔍 QR Service: Fetching active events...');
      final response = await _supabase.rpc('get_active_events');
      print('📦 QR Service: Raw events response: $response');

      if (response == null) {
        print('⚠️ QR Service: Response is null');
        return [];
      }

      final events = response.map<ScanEvent>((data) {
        print('🔧 QR Service: Processing event data: $data');
        return ScanEvent.fromJson(data);
      }).toList();

      print('✅ QR Service: Successfully loaded ${events.length} events');
      return events;
    } catch (e) {
      print('❌ QR Service: Error fetching events: ${e.toString()}');
      print('🔍 QR Service: Error type: ${e.runtimeType}');
      throw Exception('Failed to fetch events: ${e.toString()}');
    }
  }

  /// Get user meal allowances
  Future<List<MealAllowance>> getUserMealAllowances(String userId) async {
    try {
      final response = await _supabase.rpc(
        'get_user_meal_allowances',
        params: {'user_id_param': userId},
      );
      return response
          .map<MealAllowance>((data) => MealAllowance.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch meal allowances: ${e.toString()}');
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
