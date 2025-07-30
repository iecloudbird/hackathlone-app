import 'package:flutter/material.dart';
import 'package:hackathlone_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QrService {
  final SupabaseClient _client;
  final AuthService _authService;

  QrService({SupabaseClient? client, AuthService? authService})
    : _client = client ?? Supabase.instance.client,
      _authService = authService ?? AuthService();

  /// Creates a scan record when an admin scans a participant's QR code
  Future<void> createQrScanRecord({
    required String participantId,
    required String adminId,
    required String eventType,
    required String qrCodeValue,
  }) async {
    try {
      await _client.from('qr_scan_logs').insert({
        'participant_id': participantId,
        'admin_id': adminId,
        'event_type': eventType,
        'qr_code_value': qrCodeValue,
        'scanned_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating QR scan record: $e');
      throw Exception('Failed to create scan record: $e');
    }
  }

  /// Gets scan history for a participant
  Future<List<Map<String, dynamic>>> getParticipantScanHistory(
    String participantId,
  ) async {
    try {
      final response = await _client
          .from('qr_scan_logs')
          .select('*, admin:profiles!admin_id(full_name)')
          .eq('participant_id', participantId)
          .order('scanned_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching scan history: $e');
      return [];
    }
  }

  /// Gets all scans for a specific event type
  Future<List<Map<String, dynamic>>> getEventScans(String eventType) async {
    try {
      final response = await _client
          .from('qr_scan_logs')
          .select(
            '*, participant:profiles!participant_id(full_name), admin:profiles!admin_id(full_name)',
          )
          .eq('event_type', eventType)
          .order('scanned_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching event scans: $e');
      return [];
    }
  }

  /// Checks if a participant has already been scanned for a specific event
  Future<bool> hasParticipantBeenScanned(
    String participantId,
    String eventType,
  ) async {
    try {
      final response = await _client
          .from('qr_scan_logs')
          .select('id')
          .eq('participant_id', participantId)
          .eq('event_type', eventType)
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('Error checking participant scan status: $e');
      return false;
    }
  }
}
