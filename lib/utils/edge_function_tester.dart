import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class EdgeFunctionTester {
  static final _supabase = Supabase.instance.client;

  /// Test the push notification Edge Function directly
  static Future<void> testEdgeFunction(BuildContext context) async {
    try {
      print('🧪 Starting Edge Function test...');

      // Get current user's FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final userId = _supabase.auth.currentUser?.id;

      if (fcmToken == null || userId == null) {
        if (context.mounted) {
          _showResult(context, 'Error', 'Missing FCM token or user ID');
        }
        return;
      }

      print('📱 FCM Token: ${fcmToken.substring(0, 20)}...');
      print('👤 User ID: $userId');

      // Create a test notification record in database
      final testNotification = {
        'user_id': userId,
        'title': '🧪 Edge Function Test',
        'message': 'Testing Edge Function FCM integration',
        'type': 'announcement',
        'priority': 'normal',
        'sent_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      print('📝 Creating test notification in database...');
      final insertResult = await _supabase
          .from('notifications')
          .insert(testNotification)
          .select()
          .single();

      print('✅ Test notification created: ${insertResult['id']}');

      // The Edge Function should be triggered automatically by the database trigger
      // Wait a moment for the Edge Function to process
      await Future.delayed(const Duration(seconds: 3));

      if (context.mounted) {
        _showResult(
          context,
          'Test Complete',
          'Edge Function test triggered!\n\n'
              'Check your device for push notification.\n'
              'Also check Supabase Edge Function logs for details.\n\n'
              'Notification ID: ${insertResult['id']}\n'
              'FCM Token: ${fcmToken.substring(0, 20)}...',
        );
      }
    } catch (e) {
      print('❌ Edge Function test error: $e');
      if (context.mounted) {
        _showResult(context, 'Test Failed', 'Error: $e');
      }
    }
  }

  /// Test FCM credentials and configuration
  static Future<void> testFCMCredentials(BuildContext context) async {
    try {
      print('🔑 Testing FCM credentials...');

      // Call Edge Function with test payload to check credentials
      final testPayload = {
        'test_credentials': true,
        'project_id': 'hackathlone-mobile', // Your Firebase project ID
      };

      final response = await _supabase.functions.invoke(
        'pushNotifications',
        body: testPayload,
      );

      print('📡 Edge Function response: ${response.data}');

      if (context.mounted) {
        _showResult(
          context,
          'FCM Credentials Test',
          'Response: ${response.data}\n\n'
              'Check Edge Function logs for detailed credential validation.',
        );
      }
    } catch (e) {
      print('❌ FCM credentials test error: $e');
      if (context.mounted) {
        _showResult(context, 'Credentials Test Failed', 'Error: $e');
      }
    }
  }

  /// Verify Firebase project configuration
  static Future<void> verifyFirebaseConfig(BuildContext context) async {
    try {
      print('🔧 Verifying Firebase configuration...');

      final messaging = FirebaseMessaging.instance;

      // Get FCM token
      final token = await messaging.getToken();
      print('📱 FCM Token: ${token?.substring(0, 50)}...');

      // Check if Firebase is properly initialized
      await messaging.getInitialMessage();
      print('🆔 Firebase initialized successfully');

      // Check notification permissions
      final settings = await messaging.getNotificationSettings();
      print('🔔 Notification permissions: ${settings.authorizationStatus}');

      if (context.mounted) {
        _showResult(
          context,
          'Firebase Config Check',
          'FCM Token: ${token != null ? 'Available' : 'Missing'}\n'
              'Permissions: ${settings.authorizationStatus}\n'
              'Platform: ${settings.toString()}\n\n'
              'Full token (check console): ${token?.substring(0, 50)}...',
        );
      }
    } catch (e) {
      print('❌ Firebase config error: $e');
      if (context.mounted) {
        _showResult(context, 'Config Check Failed', 'Error: $e');
      }
    }
  }

  /// Show test results in a dialog
  static void _showResult(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
