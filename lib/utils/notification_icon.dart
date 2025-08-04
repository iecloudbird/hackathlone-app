import 'package:flutter/material.dart';
import 'package:hackathlone_app/models/notification/notification.dart';
import 'package:hackathlone_app/core/theme.dart';

/// Utility class for notification icon management
class NotificationIconUtils {
  /// Get icon data and color for a notification type
  static NotificationIconData getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.eventReminder:
        return NotificationIconData(
          icon: Icons.event,
          color: AppColors.brightYellow,
        );
      case NotificationType.mealReady:
        return NotificationIconData(
          icon: Icons.restaurant,
          color: AppColors.vividOrange,
        );
      case NotificationType.announcement:
        return NotificationIconData(
          icon: Icons.campaign,
          color: AppColors.spiroDiscoBall,
        );
      case NotificationType.system:
        return NotificationIconData(
          icon: Icons.settings,
          color: Colors.white70,
        );
      case NotificationType.scheduleUpdate:
        return NotificationIconData(
          icon: Icons.schedule,
          color: AppColors.brightYellow,
        );
      case NotificationType.achievement:
        return NotificationIconData(
          icon: Icons.emoji_events,
          color: AppColors.neonYellow,
        );
    }
  }
}

/// Data class to hold icon and color information
class NotificationIconData {
  final IconData icon;
  final Color color;

  const NotificationIconData({required this.icon, required this.color});
}
