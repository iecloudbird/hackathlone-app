import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification/notification.dart';
import 'notifications/service.dart' as firebase_service;

class NotificationService {
  final SupabaseClient _supabase;

  NotificationService(this._supabase);

  /// Initialize FCM token for a user
  Future<void> initializeFCMToken(String userId) async {
    try {
      final token = await firebase_service.getFCMToken();
      if (token != null) {
        await updateUserFCMToken(userId, token);
        print('🔔 FCM token initialized for user: $userId');
      }
    } catch (e) {
      print('❌ Failed to initialize FCM token: $e');
    }
  }

  /// Update user's FCM token in the database
  Future<void> updateUserFCMToken(String userId, String fcmToken) async {
    try {
      await _supabase
          .from('profiles')
          .update({'fcm_token': fcmToken})
          .eq('id', userId);
      print('💾 FCM token updated for user: $userId');
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  /// Fetch notifications for a specific user
  Future<List<AppNotification>> fetchNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((data) => AppNotification.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Send a notification to a user (both database and push)
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? actionData,
    bool sendPush = true,
  }) async {
    try {
      // Insert notification into database
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'action_data': actionData,
        'created_at': DateTime.now().toIso8601String(),
        'sent_at': DateTime.now().toIso8601String(),
      });

      // Send push notification if enabled
      if (sendPush) {
        await _sendPushNotification(userId, title, message);
      }

      print('📨 Notification sent to user: $userId');
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  /// Send push notification via FCM
  Future<void> _sendPushNotification(
    String userId,
    String title,
    String message,
  ) async {
    try {
      // Get user's FCM token
      final response = await _supabase
          .from('profiles')
          .select('fcm_token')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && response['fcm_token'] != null) {
        final fcmToken = response['fcm_token'];

        // TODO: Implement actual FCM server call here
        // This is where you'd call your backend API or FCM directly
        print(
          '⚠️  NOTICE: Push notification not sent - server implementation needed',
        );
      } else {
        print('❌ No FCM token found for user: $userId');
      }
    } catch (e) {
      print('❌ Failed to send push notification: $e');
    }
  }

  /// Broadcast notification to all users (admin only)
  Future<void> broadcastNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? actionData,
    String? userRole,
    bool sendPush = true,
  }) async {
    try {
      final response = await _supabase.rpc(
        'broadcast_notification',
        params: {
          'p_title': title,
          'p_message': message,
          'p_type': type,
          'p_action_data': actionData,
          'p_user_role': userRole,
          'p_priority': 'normal',
        },
      );

      if (response != null && response.isNotEmpty) {
        final result = response.first;
        if (result['success'] == true) {
          print('📢 ${result['message']}');
        } else {
          throw Exception(result['message']);
        }
      }
    } catch (e) {
      throw Exception('Failed to broadcast notification: $e');
    }
  }

  /// Send targeted notification to specific users (admin only)
  Future<void> sendTargetedNotifications({
    required List<String> userIds,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? actionData,
    bool sendPush = true,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      final notifications = userIds
          .map(
            (userId) => {
              'user_id': userId,
              'title': title,
              'message': message,
              'type': type,
              'action_data': actionData,
              'created_at': now,
              'sent_at': now,
            },
          )
          .toList();

      await _supabase.from('notifications').insert(notifications);

      print('🎯 Targeted notification sent to ${userIds.length} users');
    } catch (e) {
      throw Exception('Failed to send targeted notifications: $e');
    }
  }

  /// Send notification to a single specific user (admin only)
  Future<void> sendToSpecificUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? actionData,
    bool sendPush = true,
  }) async {
    try {
      // Use the database function for single user targeting
      await _supabase.rpc(
        'send_targeted_notification',
        params: {
          'p_user_id': userId,
          'p_title': title,
          'p_message': message,
          'p_type': type,
          'p_action_data': actionData,
        },
      );

      print('👤 Notification sent to specific user: $userId');
    } catch (e) {
      throw Exception('Failed to send notification to specific user: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Fetch all users for admin selection (admin only)
  Future<List<Map<String, dynamic>>> fetchUsersForSelection() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, email, role')
          .order('full_name', ascending: true);

      return response
          .map(
            (user) => {
              'id': user['id'],
              'name': user['full_name'],
              'email': user['email'],
              'role': user['role'],
              'displayText': '${user['full_name']} (${user['email']})',
            },
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Subscribe to real-time notifications for a user
  RealtimeChannel subscribeToNotifications(
    String userId,
    void Function(AppNotification) onNotification,
  ) {
    final channel = _supabase
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              final notification = AppNotification.fromJson(payload.newRecord);
              onNotification(notification);
            } catch (e) {
              print('Error parsing notification: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }
}
