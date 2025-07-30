import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification/notification.dart';

class NotificationService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => unreadNotifications.length;

  /// Fetch notifications for the current user
  Future<void> fetchNotifications({int? limit}) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var query = _supabase
          .from('notifications')
          .select()
          .or('user_id.eq.${user.id},user_id.is.null')
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      _notifications = response.map<AppNotification>((data) {
        return AppNotification(
          id: data['id'],
          userId: data['user_id'],
          title: data['title'],
          message: data['message'],
          type: NotificationType.fromString(data['type']),
          priority: NotificationPriority.fromString(
            data['priority'] ?? 'normal',
          ),
          isRead: data['is_read'] ?? false,
          actionData: data['action_data'],
          scheduledFor: data['scheduled_for'] != null
              ? DateTime.parse(data['scheduled_for'])
              : null,
          sentAt: data['sent_at'] != null
              ? DateTime.parse(data['sent_at'])
              : null,
          createdAt: DateTime.parse(data['created_at']),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch notifications: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to mark notification as read: ${e.toString()}');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .or('user_id.eq.${user.id},user_id.is.null')
          .eq('is_read', false);

      // Update local state
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to mark all notifications as read: ${e.toString()}');
      return false;
    }
  }

  /// Send a notification (admin only)
  Future<bool> sendNotification({
    String? userId, // null for broadcast
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? actionData,
    DateTime? scheduledFor,
  }) async {
    try {
      final notificationData = {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': _notificationTypeToString(type),
        'priority': _notificationPriorityToString(priority),
        'action_data': actionData,
        'scheduled_for': scheduledFor?.toIso8601String(),
      };

      await _supabase.from('notifications').insert(notificationData);

      // Refresh notifications to include the new one
      await fetchNotifications();

      return true;
    } catch (e) {
      _setError('Failed to send notification: ${e.toString()}');
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);

      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to delete notification: ${e.toString()}');
      return false;
    }
  }

  /// Subscribe to real-time notification updates
  void subscribeToNotifications() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _supabase
        .channel('notifications_${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final data = payload.newRecord;
            final notification = AppNotification(
              id: data['id'],
              userId: data['user_id'],
              title: data['title'],
              message: data['message'],
              type: NotificationType.fromString(data['type']),
              priority: NotificationPriority.fromString(
                data['priority'] ?? 'normal',
              ),
              isRead: data['is_read'] ?? false,
              actionData: data['action_data'],
              scheduledFor: data['scheduled_for'] != null
                  ? DateTime.parse(data['scheduled_for'])
                  : null,
              sentAt: data['sent_at'] != null
                  ? DateTime.parse(data['sent_at'])
                  : null,
              createdAt: DateTime.parse(data['created_at']),
            );

            _notifications.insert(0, notification);
            notifyListeners();
          },
        )
        .subscribe();
  }

  /// Unsubscribe from notifications
  void unsubscribeFromNotifications() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _supabase.removeChannel(_supabase.channel('notifications_${user.id}'));
    }
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get pending/scheduled notifications
  List<AppNotification> getPendingNotifications() {
    return _notifications.where((n) => n.isPending).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.eventReminder:
        return 'event_reminder';
      case NotificationType.mealReady:
        return 'meal_ready';
      case NotificationType.scheduleUpdate:
        return 'schedule_update';
      case NotificationType.announcement:
        return 'announcement';
      case NotificationType.achievement:
        return 'achievement';
      case NotificationType.system:
        return 'system';
    }
  }

  String _notificationPriorityToString(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'low';
      case NotificationPriority.normal:
        return 'normal';
      case NotificationPriority.high:
        return 'high';
      case NotificationPriority.urgent:
        return 'urgent';
    }
  }

  @override
  void dispose() {
    unsubscribeFromNotifications();
    super.dispose();
  }
}
