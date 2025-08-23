import 'package:hive/hive.dart';

part 'notification_preferences.g.dart';

@HiveType(typeId: 8)
class NotificationPreferences extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  bool pushNotifications;

  @HiveField(3)
  bool emailNotifications;

  @HiveField(4)
  bool eventNotifications;

  @HiveField(5)
  bool adminNotifications;

  @HiveField(6)
  bool marketingNotifications;

  @HiveField(7)
  bool emergencyAlerts;

  @HiveField(8)
  bool systemNotifications;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  NotificationPreferences({
    required this.id,
    required this.userId,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.eventNotifications = true,
    this.adminNotifications = true,
    this.marketingNotifications = false,
    this.emergencyAlerts = true,
    this.systemNotifications = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    print('🔧 NotificationPreferences.fromJson: ${json.keys}');
    return NotificationPreferences(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      eventNotifications: json['event_notifications'] as bool? ?? true,
      adminNotifications: json['admin_notifications'] as bool? ?? true,
      marketingNotifications: json['marketing_notifications'] as bool? ?? false,
      emergencyAlerts: json['emergency_alerts'] as bool? ?? true,
      systemNotifications: json['system_notifications'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'push_notifications': pushNotifications,
        'email_notifications': emailNotifications,
        'event_notifications': eventNotifications,
        'admin_notifications': adminNotifications,
        'marketing_notifications': marketingNotifications,
        'emergency_alerts': emergencyAlerts,
        'system_notifications': systemNotifications,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  NotificationPreferences copyWith({
    String? id,
    String? userId,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? eventNotifications,
    bool? adminNotifications,
    bool? marketingNotifications,
    bool? emergencyAlerts,
    bool? systemNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      eventNotifications: eventNotifications ?? this.eventNotifications,
      adminNotifications: adminNotifications ?? this.adminNotifications,
      marketingNotifications: marketingNotifications ?? this.marketingNotifications,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationPreferences(id: $id, userId: $userId, push: $pushNotifications, email: $emailNotifications, event: $eventNotifications, admin: $adminNotifications, marketing: $marketingNotifications, emergency: $emergencyAlerts, system: $systemNotifications)';
  }
}
