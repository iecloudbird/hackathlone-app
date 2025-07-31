import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/qr_scan_provider.dart';
import '../services/notification_service.dart';
import '../services/qr_scan_service.dart';

/// Service configuration for easy setup and initialization
class ServiceConfig {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<EventProvider>(create: (context) => EventProvider()),
    ChangeNotifierProvider<NotificationProvider>(
      create: (context) =>
          NotificationProvider(NotificationService(Supabase.instance.client)),
    ),
    ChangeNotifierProvider<QrScanProvider>(
      create: (context) => QrScanProvider(
        qrScanService: QrScanService(Supabase.instance.client),
      ),
    ),
  ];

  /// Initialize all services
  static Future<void> initializeServices(BuildContext context) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    // Get auth provider to check user role for debugging
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('🚀 ServiceConfig - Initializing services...');
    print('  - User authenticated: ${authProvider.isAuthenticated}');
    print('  - User role: ${authProvider.userRole ?? 'No role'}');
    print('  - Is admin: ${authProvider.isAdmin}');

    // TODO: Get current user ID from auth provider
    const String userId = 'current-user-id'; // This should come from auth

    // Fetch initial data
    await Future.wait([
      eventProvider.fetchEvents(),
      notificationProvider.loadNotifications(userId),
    ]);

    // Subscribe to real-time updates
    notificationProvider.subscribeToNotifications(userId);
    
    print('✅ ServiceConfig - Services initialized successfully');
  }

  /// Cleanup services
  static void cleanupServices(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    notificationProvider.unsubscribeFromNotifications();
  }
}

/// Service extensions for easier access
extension ServiceExtensions on BuildContext {
  EventProvider get eventProvider =>
      Provider.of<EventProvider>(this, listen: false);
  NotificationProvider get notificationProvider =>
      Provider.of<NotificationProvider>(this, listen: false);
  QrScanProvider get qrScanProvider =>
      Provider.of<QrScanProvider>(this, listen: false);

  EventProvider get watchEventProvider => Provider.of<EventProvider>(this);
  NotificationProvider get watchNotificationProvider =>
      Provider.of<NotificationProvider>(this);
  QrScanProvider get watchQrScanProvider => Provider.of<QrScanProvider>(this);
}
