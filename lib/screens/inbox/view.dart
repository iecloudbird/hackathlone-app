import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/screens/inbox/controller.dart';
import 'package:hackathlone_app/screens/inbox/widgets.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:hackathlone_app/core/constants/app_dimensions.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage>
    with SingleTickerProviderStateMixin {
  late InboxController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InboxController(context);
    _controller.initialize(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InboxHeader(controller: _controller),
        InboxTabBar(tabController: _controller.tabController),
        Expanded(
          child: TabBarView(
            controller: _controller.tabController,
            children: [
              _buildNotificationsList(showAll: true),
              _buildNotificationsList(showAll: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList({required bool showAll}) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brightYellow),
          );
        }

        if (notificationProvider.error != null) {
          return ErrorNotificationsWidget(
            error: notificationProvider.error!,
            controller: _controller,
          );
        }

        final notifications = showAll
            ? notificationProvider.notifications
            : notificationProvider.notifications
                  .where((n) => !n.isRead)
                  .toList();

        if (notifications.isEmpty) {
          return EmptyNotificationsWidget(showAll: showAll);
        }

        return RefreshIndicator(
          onRefresh: () => _controller.refreshNotifications(),
          color: AppColors.brightYellow,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return NotificationCard(
                notification: notifications[index],
                controller: _controller,
              );
            },
          ),
        );
      },
    );
  }
}
