import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/event_service.dart';
import '../services/notification_service.dart';

/// Service configuration for easy setup and initialization
class ServiceConfig {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<EventService>(create: (context) => EventService()),
    ChangeNotifierProvider<NotificationService>(
      create: (context) => NotificationService(),
    ),
  ];

  /// Initialize all services
  static Future<void> initializeServices(BuildContext context) async {
    final eventService = Provider.of<EventService>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );

    // Fetch initial data
    await Future.wait([
      eventService.fetchEvents(),
      notificationService.fetchNotifications(),
    ]);

    // Subscribe to real-time updates
    notificationService.subscribeToNotifications();
  }

  /// Cleanup services
  static void cleanupServices(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );
    notificationService.unsubscribeFromNotifications();
  }
}

/// Service extensions for easier access
extension ServiceExtensions on BuildContext {
  EventService get eventService =>
      Provider.of<EventService>(this, listen: false);
  NotificationService get notificationService =>
      Provider.of<NotificationService>(this, listen: false);

  EventService get watchEventService => Provider.of<EventService>(this);
  NotificationService get watchNotificationService =>
      Provider.of<NotificationService>(this);
}
