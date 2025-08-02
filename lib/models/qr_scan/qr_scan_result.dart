/// QR scan result model for processing scan outcomes
class QrScanResult {
  final bool success;
  final String message;
  final String? error;
  final String? userId;
  final String? fullName;
  final String? email;
  final String? scanType;
  final DateTime? timestamp;
  final int? remainingAllowance;
  final bool? isCheckedIn;
  final Map<String, dynamic>? data;

  const QrScanResult({
    required this.success,
    required this.message,
    this.error,
    this.userId,
    this.fullName,
    this.email,
    this.scanType,
    this.timestamp,
    this.remainingAllowance,
    this.isCheckedIn,
    this.data,
  });

  factory QrScanResult.fromJson(Map<String, dynamic> json) {
    return QrScanResult(
      success: json['success'] ?? false,
      message: json['message'] ?? json['error'] ?? '',
      error: json['error'],
      userId: json['user_id'],
      fullName: json['full_name'],
      email: json['email'],
      scanType: json['scan_type'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
      remainingAllowance: json['remaining_allowance'],
      isCheckedIn: json['is_checked_in'],
      data: json['data'],
    );
  }

  factory QrScanResult.success(
    String message, {
    String? userId,
    String? fullName,
    String? email,
    String? scanType,
    int? remainingAllowance,
    bool? isCheckedIn,
    Map<String, dynamic>? data,
  }) {
    return QrScanResult(
      success: true,
      message: message,
      userId: userId,
      fullName: fullName,
      email: email,
      scanType: scanType,
      timestamp: DateTime.now(),
      remainingAllowance: remainingAllowance,
      isCheckedIn: isCheckedIn,
      data: data,
    );
  }

  factory QrScanResult.error(String error) {
    return QrScanResult(
      success: false,
      message: error,
      error: error,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'error': error,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'scan_type': scanType,
      'timestamp': timestamp?.toIso8601String(),
      'remaining_allowance': remainingAllowance,
      'is_checked_in': isCheckedIn,
      'data': data,
    };
  }

  bool get isSuccess => success && error == null;
  bool get isAlreadyScanned =>
      error != null && error!.contains('Already scanned');
  bool get isInvalidCode => error != null && error!.contains('Invalid QR code');
}
