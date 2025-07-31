import 'package:flutter/material.dart';
import 'package:hackathlone_app/services/qr_scan_service.dart';

/// Provider for QR scanning operations with state management
class QrScanProvider with ChangeNotifier {
  final QrScanService _qrScanService;

  bool _isProcessing = false;
  String? _lastError;
  QrScanResult? _lastScanResult;
  List<QrScanLog> _scanHistory = [];
  QrScanStats? _scanStats;

  QrScanProvider({required QrScanService qrScanService})
    : _qrScanService = qrScanService;

  // Getters
  bool get isProcessing => _isProcessing;
  String? get lastError => _lastError;
  QrScanResult? get lastScanResult => _lastScanResult;
  List<QrScanLog> get scanHistory => _scanHistory;
  QrScanStats? get scanStats => _scanStats;

  /// Process QR code scan
  Future<QrScanResult> processQrScan({
    required String qrCode,
    required String scanType,
    String? eventId,
  }) async {
    _setProcessing(true);
    _clearError();

    try {
      final result = await _qrScanService.processQrScan(
        qrCode: qrCode,
        scanType: scanType,
        eventId: eventId,
      );

      _lastScanResult = result;

      if (!result.success && result.error != null) {
        _setError(result.error!);
      }

      // Refresh scan history and stats after successful scan
      if (result.success) {
        await _refreshScanData();
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
    try {
      _scanHistory = await _qrScanService.getUserScanLogs(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load scan history: ${e.toString()}');
    }
  }

  /// Load scan history for an event
  Future<void> loadEventScanHistory(String eventId) async {
    try {
      _scanHistory = await _qrScanService.getEventScanLogs(eventId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load event scan history: ${e.toString()}');
    }
  }

  /// Load today's meal scans for a user
  Future<List<QrScanLog>> loadTodayMealScans(String userId) async {
    try {
      return await _qrScanService.getTodayMealScans(userId);
    } catch (e) {
      _setError('Failed to load meal scans: ${e.toString()}');
      return [];
    }
  }

  /// Check if user has scanned for a specific meal today
  Future<bool> hasMealScanToday(String userId, String mealType) async {
    try {
      return await _qrScanService.hasMealScanToday(userId, mealType);
    } catch (e) {
      return false;
    }
  }

  /// Load scan statistics
  Future<void> loadScanStats() async {
    try {
      _scanStats = await _qrScanService.getScanStats();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load scan statistics: ${e.toString()}');
    }
  }

  /// Refresh scan data after a successful scan
  Future<void> _refreshScanData() async {
    await Future.wait([
      loadScanStats(),
      // Add more refresh operations as needed
    ]);
  }

  /// Clear the last scan result
  void clearLastScanResult() {
    _lastScanResult = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _isProcessing = false;
    _lastError = null;
    _lastScanResult = null;
    _scanHistory = [];
    _scanStats = null;
    notifyListeners();
  }

  // Private methods
  void _setProcessing(bool processing) {
    _isProcessing = processing;
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
