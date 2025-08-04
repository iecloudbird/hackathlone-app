import 'package:flutter/material.dart';
import 'package:hackathlone_app/services/notification_service.dart';
import 'package:hackathlone_app/models/notification/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for notification operations with state management
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  RealtimeChannel? _subscription;

  NotificationProvider({NotificationService? notificationService})
    : _notificationService =
          notificationService ?? NotificationService(Supabase.instance.client);

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Load notifications for a user
  Future<void> loadNotifications(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      _notifications = await _notificationService.fetchNotifications(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh notifications without showing loading state (for push notification updates)
  Future<void> refreshNotifications(String userId) async {
    try {
      print('🔄 Refreshing notifications due to new push notification...');
      _notifications = await _notificationService.fetchNotifications(userId);
      notifyListeners();
    } catch (e) {
      print('❌ Failed to refresh notifications: $e');
      // Don't set error state for background refreshes
    }
  }

  /// Initialize FCM token for push notifications
  Future<void> initializeFCMToken(String userId) async {
    try {
      await _notificationService.initializeFCMToken(userId);
      print('🔔 FCM token initialized for user: $userId');
    } catch (e) {
      print('❌ Failed to initialize FCM token: $e');
      _setError('Failed to setup push notifications');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          priority: _notifications[index].priority,
          isRead: true,
          actionData: _notifications[index].actionData,
          scheduledFor: _notifications[index].scheduledFor,
          sentAt: _notifications[index].sentAt,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final unreadNotifications = _notifications.where((n) => !n.isRead);

      for (final notification in unreadNotifications) {
        await _notificationService.markAsRead(notification.id);
      }

      // Update local state
      _notifications = _notifications
          .map(
            (n) => AppNotification(
              id: n.id,
              userId: n.userId,
              title: n.title,
              message: n.message,
              type: n.type,
              priority: n.priority,
              isRead: true,
              actionData: n.actionData,
              scheduledFor: n.scheduledFor,
              sentAt: n.sentAt,
              createdAt: n.createdAt,
            ),
          )
          .toList();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Send a notification (typically used by admins)
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? actionData,
  }) async {
    try {
      await _notificationService.sendNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
        actionData: actionData,
      );
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Broadcast notification to all users (admin only)
  Future<void> broadcastNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? actionData,
    String? userRole,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _notificationService.broadcastNotification(
        title: title,
        message: message,
        type: type,
        actionData: actionData,
        userRole: userRole,
      );
      print('📢 Broadcast notification sent successfully');
    } catch (e) {
      _setError(e.toString());
      print('❌ Failed to broadcast notification: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send targeted notifications to specific users (admin only)
  Future<void> sendTargetedNotifications({
    required List<String> userIds,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? actionData,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _notificationService.sendTargetedNotifications(
        userIds: userIds,
        title: title,
        message: message,
        type: type,
        actionData: actionData,
      );
      print('🎯 Targeted notifications sent successfully');
    } catch (e) {
      _setError(e.toString());
      print('❌ Failed to send targeted notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send notification to a specific user (admin only)
  Future<void> sendToSpecificUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? actionData,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _notificationService.sendToSpecificUser(
        userId: userId,
        title: title,
        message: message,
        type: type,
        actionData: actionData,
      );
      print('👤 Notification sent to specific user successfully');
    } catch (e) {
      _setError(e.toString());
      print('❌ Failed to send notification to specific user: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Subscribe to real-time notifications
  void subscribeToNotifications(String userId) {
    _subscription?.unsubscribe();

    _subscription = _notificationService.subscribeToNotifications(userId, (
      notification,
    ) {
      _notifications.insert(0, notification);
      notifyListeners();
    });
  }

  /// Unsubscribe from real-time notifications
  void unsubscribeFromNotifications() {
    _subscription?.unsubscribe();
    _subscription = null;
  }

  /// Clear all notifications
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _setError(null);
  }

  /// Fetch users for admin selection
  Future<List<Map<String, dynamic>>> fetchUsersForSelection() async {
    try {
      return await _notificationService.fetchUsersForSelection();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromNotifications();
    super.dispose();
  }
}
