// Packages imports
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/services/notifications/firebase_options.dart';
import 'package:hackathlone_app/services/notifications/service.dart'
    as notif_service;

import 'package:supabase_flutter/supabase_flutter.dart';
// Wrappers
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/providers/qr_scan_provider.dart';
import 'package:hackathlone_app/providers/timeline_provider.dart';
import 'package:hackathlone_app/utils/storage.dart';
import 'package:provider/provider.dart';

// Global navigator key for accessing GoRouter outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔔 Background message received: ${message.messageId}");
  await notif_service.showNotification(message);

  // Note: We can't refresh provider here since app is in background
  // The refresh will happen when app comes to foreground
}

/// Refresh inbox when push notification is received
void _refreshInboxOnNotification() {
  try {
    // Get the current context from navigator key
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Get current user ID
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Access NotificationProvider and refresh
        final notificationProvider = context.read<NotificationProvider>();
        notificationProvider.refreshNotifications(user.id);
        print('📬 Inbox refreshed due to new notification');
      }
    }
  } catch (e) {
    print('❌ Failed to refresh inbox: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.light, // White icons
      statusBarBrightness: Brightness.dark, // For iOS
      systemNavigationBarColor: Color(0xFF000613), // Match app gradient
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Ensure edge-to-edge rendering
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Hive cache system
  await HackCache.init();
  await dotenv.load(fileName: "assets/.env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification service
  await notif_service.initNotifications();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('🔔 Foreground message received: ${message.messageId}');
    print('📱 Title: ${message.notification?.title}');
    print('📱 Body: ${message.notification?.body}');
    print('📱 Data: ${message.data}');

    // Show notification even when app is in foreground
    await notif_service.showNotification(message);

    // Refresh inbox data when notification is received
    _refreshInboxOnNotification();
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('🔔 Notification tapped: ${message.messageId}');
    print('📱 Data: ${message.data}');

    // Refresh inbox when user taps notification
    _refreshInboxOnNotification();

    // Handle navigation based on notification data
    // You could navigate to specific screens based on message.data
  });

  // Move this to its own function and file
  final appLinks = AppLinks();
  Uri? initialUri = await appLinks.getInitialLink();
  print('Initial link: $initialUri');
  if (initialUri != null) {
    print(
      'Scheme: ${initialUri.scheme}, Host: ${initialUri.host}, Path: ${initialUri.path}',
    );
    print('Query parameters: ${initialUri.queryParameters}');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QrScanProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => TimelineProvider()),
      ],
      child: MyApp(initialUri: initialUri),
    ),
  );

  appLinks.uriLinkStream.listen((uri) {
    //Removing logginng soon after Provider and fallback is working
    print('Stream link: $uri');
    print('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    print('Query parameters: ${uri.queryParameters}');
    final token = uri.queryParameters['token'];
    final type = uri.queryParameters['type'];
    if (navigatorKey.currentContext != null) {
      if (token != null && type != null) {
        GoRouter.of(
          navigatorKey.currentContext!,
        ).go(AppRoutes.authAction, extra: {'type': type, 'token': token});
      } else if (uri.path == '/' || uri.path.isEmpty) {
        GoRouter.of(navigatorKey.currentContext!).go(AppRoutes.login);
      }
    }
  });

  SemanticsBinding.instance.ensureSemantics(); //Automatically enable semantics
}

class MyApp extends StatelessWidget {
  final Uri? initialUri;
  const MyApp({super.key, this.initialUri});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hackathlone App',
      theme: ThemeData(
        primaryColor: const Color(0xFF0042A6),
        fontFamily: 'Overpass',
        useMaterial3: true,
        scaffoldBackgroundColor:
            Colors.transparent, // Ensure no default white background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0042A6),
          brightness: Brightness.dark, // Align with dark theme
          surface: const Color(0xFF000613), // Match gradient start
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      routerConfig: AppRoutes.getRouter(
        navigatorKey: navigatorKey,
        initialLocation: _getInitialLocation(),
      ),
      builder: (context, child) {
        return AppLifecycleWrapper(child: child!);
      },
    );
  }

  String _getInitialLocation() {
    if (Supabase.instance.client.auth.currentSession != null) {
      return AppRoutes.home;
    } else if (initialUri != null) {
      if (initialUri!.path.startsWith('/auth_action')) {
        return AppRoutes.authAction;
      } else if (initialUri!.path == '/' || initialUri!.path.isEmpty) {
        return AppRoutes.login;
      }
    }
    return AppRoutes.login;
  }
}

/// Wrapper to handle app lifecycle changes and refresh inbox when app resumes
class AppLifecycleWrapper extends StatefulWidget {
  final Widget child;

  const AppLifecycleWrapper({super.key, required this.child});

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Refresh inbox when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      print(
        '📱 App resumed - refreshing inbox for any background notifications...',
      );
      _refreshInboxOnNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
