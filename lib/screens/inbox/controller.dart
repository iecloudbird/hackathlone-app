import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/models/notification/notification.dart';
import 'package:hackathlone_app/core/constants/app_dimensions.dart';
import 'package:hackathlone_app/core/constants/app_text_styles.dart';
import 'package:hackathlone_app/utils/time_utils.dart';
import 'package:hackathlone_app/utils/notification_icon.dart';
import 'package:hackathlone_app/screens/inbox/widgets.dart';

class InboxController {
  final BuildContext context;
  late TabController tabController;

  InboxController(this.context);

  void initialize(TickerProvider vsync) {
    tabController = TabController(length: 2, vsync: vsync);
    _loadNotifications();
  }

  /// Clean up resources
  void dispose() {
    tabController.dispose();
  }

  /// Load notifications for the current user
  void _loadNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<NotificationProvider>().loadNotifications(
          authProvider.user!.id,
        );
      }
    });
  }

  /// Refresh notifications from server
  Future<void> refreshNotifications() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await context.read<NotificationProvider>().loadNotifications(
        authProvider.user!.id,
      );
    }
  }

  /// Mark a single notification as read
  void markNotificationAsRead(String notificationId) {
    final notificationProvider = context.read<NotificationProvider>();
    notificationProvider.markAsRead(notificationId);
  }

  /// Mark all notifications as read
  void markAllNotificationsAsRead() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<NotificationProvider>().markAllAsRead(authProvider.user!.id);
    }
  }

  /// Show confirmation dialog for marking all as read
  void showMarkAllAsReadDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildMarkAllAsReadDialog(),
    );
  }

  /// Handle notification tap - mark as read and show detail sheet
  void handleNotificationTap(
    String notificationId,
    bool isRead,
    AppNotification notification,
  ) {
    if (!isRead) {
      markNotificationAsRead(notificationId);
    }

    // Show notification detail in bottom sheet
    showNotificationDetail(notification);
  }

  /// Show notification detail in a bottom sheet
  void showNotificationDetail(AppNotification notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationDetailSheet(notification),
    );
  }

  /// Build the mark all as read confirmation dialog
  Widget _buildMarkAllAsReadDialog() {
    return AlertDialog(
      backgroundColor: AppColors.deepBlue,
      title: const Text(
        'Mark all as read?',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'This will mark all notifications as read.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            markAllNotificationsAsRead();
          },
          child: const Text(
            'Mark all read',
            style: TextStyle(color: AppColors.brightYellow),
          ),
        ),
      ],
    );
  }

  /// Build the notification detail bottom sheet
  Widget _buildNotificationDetailSheet(AppNotification notification) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.maastrichtBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusL),
          topRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.paddingS),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationTypeIcon(notification.type),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppTextStyles.headingMedium,
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        TimeUtils.formatDetailedRelativeTime(
                          notification.createdAt,
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.brightYellow,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showRemoveNotificationDialog(notification);
                      },
                      icon: const Icon(
                        IconsaxPlusLinear.trash,
                        color: AppColors.rocketRed,
                      ),
                      tooltip: 'Remove notification',
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
            ),
            child: Divider(
              color: Colors.white.withValues(alpha: 0.5),
              thickness: 1,
            ),
          ),
          // Content
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingS,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notification.message.isNotEmpty) ...[
                        Text(
                          'Message:',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.brightYellow,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Text(
                          notification.message,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: AppDimensions.paddingL),
                      ],
                      // Can create utils for parsing link, urls, time date venue etc.
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build notification type icon for detail view
  Widget _buildNotificationTypeIcon(NotificationType type) {
    final iconData = NotificationIconUtils.getIconData(type);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: iconData.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Icon(
        iconData.icon,
        color: iconData.color,
        size: AppDimensions.iconM,
      ),
    );
  }

  /// Show remove notification confirmation dialog
  void showRemoveNotificationDialog(AppNotification notification) {
    RemoveNotificationDialog.show(
      context,
      notification.title,
      onConfirm: () => removeNotification(notification.id),
    );
  }

  /// Remove a specific notification
  Future<void> removeNotification(String notificationId) async {
    try {
      await context.read<NotificationProvider>().deleteNotification(
        notificationId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification removed'),
            backgroundColor: AppColors.brightYellow,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove notification: ${e.toString()}'),
            backgroundColor: AppColors.rocketRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Remove a specific notification silently (for swipe-to-delete)
  Future<void> removeNotificationSilently(String notificationId) async {
    try {
      await context.read<NotificationProvider>().deleteNotification(
        notificationId,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove notification: ${e.toString()}'),
            backgroundColor: AppColors.rocketRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
