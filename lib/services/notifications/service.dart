import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: android);
  await notifications.initialize(initSettings);
}

Future<void> showNotification(RemoteMessage message) async {
  const androidDetails = AndroidNotificationDetails(
    'default_channel',
    'Default Channel',
    importance: Importance.max,
    priority: Priority.high,
  );
  const platformDetails = NotificationDetails(android: androidDetails);
  await notifications.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformDetails,
  );
}

// retrieves FCM token for push notifications
Future<String?> getFCMToken() async {
  try {
    final messaging = FirebaseMessaging.instance;

    // Request permission first
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 FCM Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      print('🎯 FCM Token retrieved: ${token?.substring(0, 20)}...');
      return token;
    } else {
      print('❌ FCM Permission denied');
      return null;
    }
  } catch (e) {
    print('❌ Error getting FCM token: $e');
    return null;
  }
}
