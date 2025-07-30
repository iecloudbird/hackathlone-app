import 'package:hive/hive.dart';

part 'info.g.dart';

@HiveType(typeId: 2)
class QrCode {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String qrCode;
  @HiveField(3)
  final String type;
  @HiveField(4)
  final DateTime? createdAt;
  @HiveField(5)
  final bool used;

  QrCode({
    required this.id,
    required this.userId,
    required this.qrCode,
    required this.type,
    this.createdAt,
    this.used = false,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      qrCode: json['qr_code'] as String,
      type: json['type'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      used: json['used'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'qr_code': qrCode,
    'type': type,
    'created_at': createdAt?.toIso8601String(),
    'used': used,
  };
}
