/// QR scan statistics model
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

  Map<String, dynamic> toJson() {
    return {
      'total_scans': totalScans,
      'today_scans': todayScans,
      'breakfast_scans': breakfastScans,
      'lunch_scans': lunchScans,
      'dinner_scans': dinnerScans,
      'checkin_scans': checkinScans,
    };
  }
}
