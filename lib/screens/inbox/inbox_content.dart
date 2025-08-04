import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/models/notification/notification.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/app_dimensions.dart';
import 'package:hackathlone_app/core/constants/app_text_styles.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class InboxContent extends StatefulWidget {
  const InboxContent({super.key});

  @override
  State<InboxContent> createState() => _InboxContentState();
}

class _InboxContentState extends State<InboxContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load notifications on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<NotificationProvider>().loadNotifications(
          authProvider.user!.id,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(child: _buildTabBarView()),
      ],
    );
  }

  Widget _buildHeader() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;

        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              const Icon(
                IconsaxPlusLinear.sms,
                color: AppColors.spiroDiscoBall,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Inbox', style: AppTextStyles.headingLarge),
                    if (unreadCount > 0)
                      Text(
                        '$unreadCount unread message${unreadCount == 1 ? '' : 's'}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.spiroDiscoBall,
                        ),
                      ),
                  ],
                ),
              ),
              if (notificationProvider.notifications.isNotEmpty)
                IconButton(
                  onPressed: () => _showMarkAllAsReadDialog(),
                  icon: const Icon(
                    IconsaxPlusLinear.tick_circle,
                    color: AppColors.spiroDiscoBall,
                  ),
                  tooltip: 'Mark all as read',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.maastrichtBlue,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.deepBlue.withValues(alpha: 0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.spiroDiscoBall,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
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

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotificationsList(showAll: true),
        _buildNotificationsList(showAll: false),
      ],
    );
  }

  Widget _buildNotificationsList({required bool showAll}) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.spiroDiscoBall),
          );
        }

        if (notificationProvider.error != null) {
          return _buildErrorWidget(notificationProvider.error!);
        }

        final notifications = showAll
            ? notificationProvider.notifications
            : notificationProvider.notifications
                  .where((n) => !n.isRead)
                  .toList();

        if (notifications.isEmpty) {
          return _buildEmptyWidget(showAll);
        }

        return RefreshIndicator(
          onRefresh: () {
            final authProvider = context.read<AuthProvider>();
            if (authProvider.user != null) {
              return notificationProvider.loadNotifications(
                authProvider.user!.id,
              );
            }
            return Future.value();
          },
          color: AppColors.spiroDiscoBall,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationCard(notifications[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.maastrichtBlue.withValues(alpha: 0.5)
            : AppColors.maastrichtBlue,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: notification.isRead
              ? AppColors.deepBlue.withValues(alpha: 0.3)
              : AppColors.spiroDiscoBall.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildNotificationIcon(notification.type),
                  const SizedBox(width: AppDimensions.paddingS),
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
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.spiroDiscoBall,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              if (notification.message.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.paddingS),
                Text(
                  notification.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: notification.isRead ? Colors.white70 : Colors.white,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.eventReminder:
        icon = IconsaxPlusLinear.calendar;
        color = AppColors.spiroDiscoBall;

      case NotificationType.mealReady:
        icon = IconsaxPlusLinear.cake;
        color = AppColors.brightYellow;

      case NotificationType.announcement:
        icon = IconsaxPlusLinear.speaker;
        color = AppColors.vividOrange;

      case NotificationType.system:
        icon = IconsaxPlusLinear.setting_2;
        color = Colors.white70;

      case NotificationType.scheduleUpdate:
        icon = IconsaxPlusLinear.calendar_edit;
        color = AppColors.spiroDiscoBall;

      case NotificationType.achievement:
        icon = IconsaxPlusLinear.medal;
        color = AppColors.brightYellow;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildEmptyWidget(bool showAll) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(IconsaxPlusLinear.sms, size: 64, color: Colors.white38),
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

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            IconsaxPlusLinear.warning_2,
            size: 64,
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
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.user != null) {
                context.read<NotificationProvider>().loadNotifications(
                  authProvider.user!.id,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.spiroDiscoBall,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.markAsRead(notification.id);
    }

    // Handle different notification actions based on type or data
    // You can add navigation logic here based on notification.data
  }

  void _showMarkAllAsReadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.maastrichtBlue,
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final authProvider = context.read<AuthProvider>();
              if (authProvider.user != null) {
                context.read<NotificationProvider>().markAllAsRead(
                  authProvider.user!.id,
                );
              }
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.spiroDiscoBall),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
