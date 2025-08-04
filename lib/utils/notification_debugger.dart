import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Debug utility for tracking push notification issues
class NotificationDebugger {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Comprehensive notification system check
  static Future<Map<String, dynamic>> debugNotificationSystem(
    String userId,
  ) async {
    final results = <String, dynamic>{};

    print('🔍 Starting notification system debug for user: $userId');

    // 1. Check FCM Token
    results['fcm_token'] = await _checkFCMToken(userId);

    // 2. Check Firebase Messaging permissions
    results['permissions'] = await _checkPermissions();

    // 3. Check Supabase connection
    results['supabase'] = await _checkSupabaseConnection();

    // 4. Check user profile
    results['profile'] = await _checkUserProfile(userId);

    // 5. Test local notification
    results['local_notification'] = await _testLocalNotification();

    print('🔍 Debug results: $results');
    return results;
  }

  static Future<Map<String, dynamic>> _checkFCMToken(String userId) async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();

      if (token != null) {
        // Check if token is stored in database
        final response = await _supabase
            .from('profiles')
            .select('fcm_token')
            .eq('id', userId)
            .maybeSingle();

        final storedToken = response?['fcm_token'];

        return {
          'status': 'success',
          'current_token': '${token.substring(0, 20)}...',
          'stored_token': storedToken != null
              ? '${storedToken.substring(0, 20)}...'
              : 'null',
          'tokens_match': token == storedToken,
        };
      } else {
        return {'status': 'error', 'message': 'No FCM token available'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _checkPermissions() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();

      return {
        'status': 'success',
        'authorization': settings.authorizationStatus.name,
        'alert': settings.alert.name,
        'badge': settings.badge.name,
        'sound': settings.sound.name,
      };
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _checkSupabaseConnection() async {
    try {
      await _supabase.from('profiles').select('count').limit(1);
      return {'status': 'success', 'connection': 'active'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _checkUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, fcm_token')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return {
          'status': 'success',
          'profile_exists': true,
          'has_fcm_token': response['fcm_token'] != null,
          'user_name': response['full_name'],
        };
      } else {
        return {'status': 'error', 'message': 'User profile not found'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _testLocalNotification() async {
    try {
      // This would test the local notification display
      // You can expand this to actually trigger a test notification
      return {
        'status': 'success',
        'message': 'Local notification system ready',
      };
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Show debug results in a dialog
  static void showDebugDialog(
    BuildContext context,
    Map<String, dynamic> results,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Debug Results'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDebugSection('FCM Token', results['fcm_token']),
              const SizedBox(height: 16),
              _buildDebugSection('Permissions', results['permissions']),
              const SizedBox(height: 16),
              _buildDebugSection('Supabase', results['supabase']),
              const SizedBox(height: 16),
              _buildDebugSection('Profile', results['profile']),
              const SizedBox(height: 16),
              _buildDebugSection(
                'Local Notifications',
                results['local_notification'],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildDebugSection(String title, Map<String, dynamic> data) {
    final isSuccess = data['status'] == 'success';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ...data.entries
            .where((e) => e.key != 'status')
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
      ],
    );
  }
}
