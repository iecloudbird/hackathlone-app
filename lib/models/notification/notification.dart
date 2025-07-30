import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 5)
class AppNotification {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String message;

  @HiveField(4)
  final NotificationType type;

  @HiveField(5)
  final NotificationPriority priority;

  @HiveField(6)
  final bool isRead;

  @HiveField(7)
  final Map<String, dynamic>? actionData;

  @HiveField(8)
  final DateTime? scheduledFor;

  @HiveField(9)
  final DateTime? sentAt;

  @HiveField(10)
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    this.actionData,
    this.scheduledFor,
    this.sentAt,
    required this.createdAt,
  });

  // JSON serialization without json_annotation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'is_read': isRead,
      'action_data': actionData,
      'scheduled_for': scheduledFor?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.fromString(json['type']),
      priority: NotificationPriority.fromString(json['priority'] ?? 'normal'),
      isRead: json['is_read'] ?? false,
      actionData: json['action_data'],
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'])
          : null,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    Map<String, dynamic>? actionData,
    DateTime? scheduledFor,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      actionData: actionData ?? this.actionData,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPending => scheduledFor != null && sentAt == null;
  bool get isSent => sentAt != null;
  bool get isScheduled => scheduledFor != null;
}

@HiveType(typeId: 6)
enum NotificationType {
  @HiveField(0)
  eventReminder,

  @HiveField(1)
  mealReady,

  @HiveField(2)
  scheduleUpdate,

  @HiveField(3)
  announcement,

  @HiveField(4)
  achievement,

  @HiveField(5)
  system;

  String get displayName {
    switch (this) {
      case NotificationType.eventReminder:
        return 'Event Reminder';
      case NotificationType.mealReady:
        return 'Meal Ready';
      case NotificationType.scheduleUpdate:
        return 'Schedule Update';
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.achievement:
        return 'Achievement';
      case NotificationType.system:
        return 'System';
    }
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'event_reminder':
        return NotificationType.eventReminder;
      case 'meal_ready':
        return NotificationType.mealReady;
      case 'schedule_update':
        return NotificationType.scheduleUpdate;
      case 'announcement':
        return NotificationType.announcement;
      case 'achievement':
        return NotificationType.achievement;
      default:
        return NotificationType.system;
    }
  }
}

@HiveType(typeId: 7)
enum NotificationPriority {
  @HiveField(0)
  low,

  @HiveField(1)
  normal,

  @HiveField(2)
  high,

  @HiveField(3)
  urgent;

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  static NotificationPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }
}
