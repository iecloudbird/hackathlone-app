import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/qr_scan_service.dart';
import '../models/qr_scan/qr_scan.dart';

/// Provider for QR scanning operations with state management
class QrScanProvider extends ChangeNotifier {
  late final QrScanService _service;

  QrScanResult? _lastScanResult;
  List<QrScanLog> _scanHistory = [];
  List<ScanEvent> _activeEvents = [];
  List<MealAllowance> _mealAllowances = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  QrScanProvider() {
    _service = QrScanService(Supabase.instance.client);
  }

  // Getters
  QrScanResult? get lastScanResult => _lastScanResult;
  List<QrScanLog> get scanHistory => _scanHistory;
  List<ScanEvent> get activeEvents => _activeEvents;
  List<MealAllowance> get mealAllowances => _mealAllowances;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  /// Load active events
  Future<void> loadActiveEvents() async {
    _setLoading(true);
    _clearError();

    try {
      _activeEvents = await _service.getActiveEvents();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load events: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load user meal allowances
  Future<void> loadUserMealAllowances(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _mealAllowances = await _service.getUserMealAllowances(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load meal allowances: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Process QR code scan
  Future<QrScanResult> processQrScan({
    required String qrCode,
    required String scanType,
    String? eventId,
  }) async {
    _setProcessing(true);
    _clearError();

    try {
      final result = await _service.processQrScan(
        qrCode: qrCode,
        scanType: scanType,
        eventId: eventId,
      );

      _lastScanResult = result;

      if (!result.success && result.error != null) {
        _setError(result.error!);
      }

      // Refresh data after successful scan
      if (result.success) {
        // Could refresh scan history and allowances here
      }

      return result;
    } catch (e) {
      final error = 'QR scan failed: ${e.toString()}';
      _setError(error);
      return QrScanResult.error(error);
    } finally {
      _setProcessing(false);
    }
  }

  /// Load scan history for a user
  Future<void> loadUserScanHistory(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _scanHistory = await _service.getUserScanLogs(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load scan history: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load scan history for an event
  Future<void> loadEventScanHistory(String eventId) async {
    _setLoading(true);
    _clearError();

    try {
      _scanHistory = await _service.getEventScanLogs(eventId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load event scan history: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load today's meal scans for a user
  Future<List<QrScanLog>> loadTodayMealScans(String userId) async {
    try {
      return await _service.getTodayMealScans(userId);
    } catch (e) {
      _setError('Failed to load meal scans: ${e.toString()}');
      return [];
    }
  }

  /// Check if user has scanned for a specific meal today
  Future<bool> hasMealScanToday(String userId, String mealType) async {
    try {
      return await _service.hasMealScanToday(userId, mealType);
    } catch (e) {
      return false;
    }
  }

  /// Get scan statistics
  Future<QrScanStats> getScanStats() async {
    try {
      return await _service.getScanStats();
    } catch (e) {
      _setError('Failed to load scan statistics: ${e.toString()}');
      return QrScanStats.empty();
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearLastScanResult() {
    _lastScanResult = null;
    notifyListeners();
  }

  void clearScanHistory() {
    _scanHistory.clear();
    notifyListeners();
  }
}
