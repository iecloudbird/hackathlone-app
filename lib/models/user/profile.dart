import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 0)
class UserProfile {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String? phone;
  @HiveField(3)
  final String role;
  @HiveField(4)
  final String fullName;
  @HiveField(5)
  final String? bio;
  @HiveField(6)
  final String? dietaryPreferences;
  @HiveField(7)
  final String? tshirtSize;
  @HiveField(8)
  final String? qrCode;
  @HiveField(9)
  final String? avatarUrl;
  @HiveField(10)
  final DateTime? createdAt;
  @HiveField(11)
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.phone,
    required this.role,
    required this.fullName,
    this.bio,
    this.dietaryPreferences,
    this.tshirtSize,
    this.qrCode,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      fullName: json['full_name'] as String,
      bio: json['bio'] as String?,
      dietaryPreferences: json['dietary_preferences'] as String?,
      tshirtSize: json['tshirt_size'] as String?,
      qrCode: json['qr_code'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'phone': phone,
    'role': role,
    'full_name': fullName,
    'bio': bio,
    'dietary_preferences': dietaryPreferences,
    'tshirt_size': tshirtSize,
    'qr_code': qrCode,
    'avatar_url': avatarUrl,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
