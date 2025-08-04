import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/models/notification/notification.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/app_dimensions.dart';
import 'package:hackathlone_app/core/constants/app_text_styles.dart';
import 'package:hackathlone_app/utils/time_utils.dart';
import 'package:hackathlone_app/utils/notification_icon.dart';
import 'package:hackathlone_app/screens/inbox/controller.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Inbox header widget with title and unread count
class InboxHeader extends StatelessWidget {
  final InboxController controller;

  const InboxHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;

        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Updates & Alerts',
                      style: AppTextStyles.headingMedium,
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        '$unreadCount unread message${unreadCount == 1 ? '' : 's'}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.brightYellow,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (notificationProvider.notifications.isNotEmpty)
                IconButton(
                  onPressed: () => controller.showMarkAllAsReadDialog(),
                  icon: const Icon(
                    IconsaxPlusLinear.tick_circle,
                    color: AppColors.brightYellow,
                  ),
                  tooltip: 'Mark all as read',
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom tab bar for All/Unread notifications
class InboxTabBar extends StatelessWidget {
  final TabController tabController;

  const InboxTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.deepBlue,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.maastrichtBlue.withValues(alpha: 0.3),
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: AppColors.brightYellow,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.deepBlue,
        unselectedLabelColor: Colors.white70,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Unread'),
        ],
      ),
    );
  }
}

/// Individual notification card widget
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final InboxController controller;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.maastrichtBlue.withValues(alpha: 0.8)
            : AppColors.maastrichtBlue,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: notification.isRead
              ? AppColors.maastrichtBlue.withValues(alpha: 0.5)
              : AppColors.brightYellow.withValues(alpha: 0.7),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () => controller.handleNotificationTap(
          notification.id,
          notification.isRead,
          notification,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  NotificationIcon(type: notification.type),
                  if (!notification.isRead) ...[
                    const SizedBox(height: AppDimensions.paddingXS),
                    Container(
                      width: AppDimensions.paddingS,
                      height: AppDimensions.paddingS,
                      decoration: const BoxDecoration(
                        color: AppColors.brightYellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: AppDimensions.paddingM),
              // Content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${TimeUtils.formatRelativeTime(notification.createdAt)} ago',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    if (notification.message.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: notification.isRead
                              ? Colors.white70
                              : Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notification type icon with color coding
class NotificationIcon extends StatelessWidget {
  final NotificationType type;

  const NotificationIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final iconData = NotificationIconUtils.getIconData(type);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXS),
      decoration: BoxDecoration(
        color: iconData.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Icon(
        iconData.icon,
        color: iconData.color,
        size: AppDimensions.iconL,
      ),
    );
  }
}

/// Empty state widget for when there are no notifications
class EmptyNotificationsWidget extends StatelessWidget {
  final bool showAll;

  const EmptyNotificationsWidget({super.key, required this.showAll});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconsaxPlusLinear.message_remove,
            size: AppDimensions.iconXL * 1.33,
            color: Colors.white38,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            showAll ? 'No notifications yet' : 'No unread notifications',
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            showAll
                ? 'You\'ll see important updates and announcements here'
                : 'All caught up! Check back later for updates',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Error state widget for when loading fails
class ErrorNotificationsWidget extends StatelessWidget {
  final String error;
  final InboxController controller;

  const ErrorNotificationsWidget({
    super.key,
    required this.error,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            IconsaxPlusLinear.warning_2,
            size: AppDimensions.iconXL * 1.33,
            color: AppColors.rocketRed,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          const Text(
            'Failed to load notifications',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          ElevatedButton(
            onPressed: () => controller.refreshNotifications(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brightYellow,
              foregroundColor: AppColors.deepBlue,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
